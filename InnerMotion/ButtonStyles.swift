import SwiftUI

//========================
// BUTTON STYLES
// ستايلات موحدة لكل الأزرار: تتحول أبيض وقت الضغط بس (لحظي)
// وترجع للونها الأساسي تلقائي أول ما ترفعين إصبعك — بدون ما تعلق بحالة معينة
//========================

// للأزرار الطويلة (Start First Step, Make it Easier, Start Task, Back to My Steps)
struct PressableCapsuleStyle: ButtonStyle {

    var fillColor: Color
    var cornerRadius: CGFloat = 30

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? fillColor : .white)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(configuration.isPressed ? Color.white : fillColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(fillColor, lineWidth: 2)
            )
    }
}

// للأزرار الدائرية اللي فيها أيقونة بس (Done, Take a Break)
struct PressableCircleIconStyle: ButtonStyle {

    var fillColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? fillColor : .white)
            .background(
                Circle()
                    .fill(configuration.isPressed ? Color.white : fillColor)
            )
            .overlay(
                Circle()
                    .stroke(fillColor, lineWidth: 2)
            )
    }
}

// لأيقونات صغيرة زي الهوم والباك (بدون خلفية دائرية، بس يتغير لون الأيقونة نفسها لحظيًا)
struct PressableIconStyle: ButtonStyle {

    var normalColor: Color
    var pressedColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? pressedColor : normalColor)
    }
}
