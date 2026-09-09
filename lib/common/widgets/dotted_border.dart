import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class DottedBorderBox extends StatelessWidget {
  final double? height;
  final double? width;
  final Function() onTap;
  final bool showErrorBorder;
  const DottedBorderBox({super.key, required this.onTap, this.height=100, this.width=100,this.showErrorBorder = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        dashPattern: const [8, 4],
        strokeWidth: 1,
        borderType: BorderType.RRect,
        color: showErrorBorder ? Theme.of(context).colorScheme.error : Theme.of(context).hintColor,
        radius: const Radius.circular(10),
        child: SizedBox(height: height, width: width,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload_rounded,
                  color: showErrorBorder ? Theme.of(context).colorScheme.error : Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.6),
                  size: 30,
                ),
                const SizedBox(height: 5,),
                Text("upload_file".tr, textAlign: TextAlign.center,
                  style: robotoMedium.copyWith(fontSize: 12,
                    color:showErrorBorder ? Theme.of(context).colorScheme.error : Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
