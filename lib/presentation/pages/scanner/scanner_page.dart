import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tochka_balansa/core/l10n/language_manager.dart';
import 'package:tochka_balansa/core/theme/colors.dart';
import 'package:tochka_balansa/data/models/product/scanned_product.dart';
import 'package:tochka_balansa/presentation/widgets/app_bar.dart';
import 'package:tochka_balansa/services/product_database_service.dart';
import 'package:tochka_balansa/presentation/widgets/add_product_dialog.dart';

class ScannerPage extends StatefulWidget {
  final Function(String)? onScanned;

  const ScannerPage({super.key, this.onScanned});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  MobileScannerController controller = MobileScannerController();
  bool isFlashOn = false;
  bool isCameraPermissionGranted = false;
  bool _mounted = true; // Добавляем флаг для проверки состояния

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  @override
  void dispose() {
    _mounted = false; // Устанавливаем флаг при dispose
    controller.dispose();
    super.dispose();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    setState(() {
      isCameraPermissionGranted = status.isGranted;
    });
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      isCameraPermissionGranted = status.isGranted;
    });
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      final String code = barcode.rawValue ?? '';
      if (code.isNotEmpty) {
        _onScanned(code, barcode);
      }
    }
  }

  void _onScanned(String code, Barcode barcode) async {
    if (!_mounted) return;

    controller.stop();

    // Ищем в локальной базе продуктов
    ScannedProduct? product = await ProductDatabaseService.findProductByBarcode(
      code,
    );

    if (!_mounted) return;

    if (product != null) {
      // Продукт найден в базе
      _showProductFoundDialog(product);
    } else {
      // Продукт не найден, возвращаем штрих-код
      Navigator.of(context).pop({'barcode': code});
    }
  }

  void _showProductFoundDialog(ScannedProduct product) {
    if (!_mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(textLang('Продукт найден')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (product.description != null) ...[
                Text(product.description!),
                const SizedBox(height: 8),
              ],
              Text(
                'Количество: ${product.totalQuantity} ${product.quantityUnit}',
                style: TextStyle(color: AppColor.greyText),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_mounted) controller.start();
              },
              child: Text(textLang('Отмена')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Передаем полную информацию о продукте
                Navigator.of(context).pop({
                  'name': product.name,
                  'totalQuantity': product.totalQuantity,
                  'quantityUnit': product.quantityUnit,
                });
                widget.onScanned?.call(product.name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.darkBlue,
                foregroundColor: Colors.white,
              ),
              child: Text(textLang('Использовать')),
            ),
          ],
        );
      },
    );
  }

  void showAddProductDialog(String barcode) {
    if (!_mounted) return;

    // Сохраняем контекст заранее
    final navigatorContext = context;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(textLang('Продукт не найден')),
          content: Text(
            textLang(
              'Продукт с кодом $barcode не найден в базе данных. Хотите добавить его?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (_mounted) controller.start();
              },
              child: Text(textLang('Отмена')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                if (!_mounted) return;

                final result = await showDialog<ScannedProduct>(
                  context: navigatorContext,
                  builder: (context) => AddProductDialog(barcode: barcode),
                );

                if (!_mounted) return;

                if (result != null) {
                  // Передаем полную информацию о продукте
                  // ignore: use_build_context_synchronously
                  Navigator.of(navigatorContext).pop({
                    'name': result.name,
                    'totalQuantity': result.totalQuantity,
                    'quantityUnit': result.quantityUnit,
                  });
                  widget.onScanned?.call(result.name);
                } else {
                  if (_mounted) controller.start();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.darkBlue,
                foregroundColor: Colors.white,
              ),
              child: Text(textLang('Добавить')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraPermissionGranted) {
      return Scaffold(
        appBar: AppBarWidget(title: textLang('Сканер'), isBack: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: AppColor.greyText.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                textLang('Требуется разрешение на камеру'),
                style: TextStyle(
                  fontSize: 18,
                  color: AppColor.greyText.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.darkBlue,
                  foregroundColor: Colors.white,
                ),
                child: Text(textLang('Предоставить разрешение')),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBarWidget(
        title: textLang('Сканер'),
        isBack: true,
        actions: [
          IconButton(
            onPressed: () async {
              await controller.toggleTorch();
              setState(() {
                isFlashOn = !isFlashOn;
              });
            },
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  textLang('Наведите камеру на QR-код или штрих-код'),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
