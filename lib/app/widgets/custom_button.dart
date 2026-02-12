import '../../exports.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool isBorderEnable;
  final bool? loading;
  final double? width;
  final Color? textColor;
  final Color? borderColor;
  final Color? color;
  final Function() onPressed;
  final Widget? buttonCenter;
  final double? buttonHeight;
  final double? borderWidth;
  final TextStyle? textStyle;
  final EdgeInsets? margin;
  final double? radius;
  final double? fontSize;
  final String? textFont;
  final FontWeight? fontWeight;

  const CustomButton({
    super.key,
    this.width,
    this.isBorderEnable = false,
    this.textColor,
    this.color,
    this.borderWidth,
    this.buttonCenter,
    this.buttonHeight,
    required this.text,
    this.loading = false,
    this.borderColor,
    required this.onPressed,
    this.textStyle,
    this.margin,
    this.radius,
    this.textFont,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(radius ?? 50),
      ),
      height: buttonHeight ?? 45,
      margin: margin ?? EdgeInsets.zero,
      width: width ?? MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: loading == true ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColor.appColor,
          shadowColor: AppColor.appColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 10),
            side: isBorderEnable == true
                ? BorderSide(
                    color: borderColor ?? Colors.black,
                    width: borderWidth ?? 1.0,
                  )
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: loading == true
            ? SizedBox(
                height: 25,
                width: 25,
                child: const CircularProgressIndicator(color: Colors.white),
              )
            : buttonCenter ??
                  Text(
                    text,
                    style:
                        textStyle ??
                        TextStyle(
                          // fontFamily: textFont ?? FontFamily.urbanist,
                          fontSize: fontSize ?? 20,
                          color: textColor ?? AppColor.white,
                          letterSpacing: 1.5,
                          fontWeight: fontWeight ?? FontWeight.w600,
                        ),
                  ),
      ),
    );
  }
}
