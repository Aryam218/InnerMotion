import SwiftUI

//========================
// COLORS
// ملف واحد بس لكل الألوان بالمشروع
// لا تكررين تعريف extension Color بأي ملف ثاني
//========================

extension Color {

    static let backgroundColor = Color(red: 254/255, green: 247/255, blue: 241/255) //FEF7F1
    static let primaryText = Color(red: 55/255, green: 0/255, blue: 138/255) //37008A
    static let secondaryText = Color(red: 86/255, green: 61/255, blue: 106/255) //563D6A
    static let primaryButton = Color(red: 117/255, green: 96/255, blue: 142/255) //75608E
    static let secondaryButton = Color(red: 168/255, green: 151/255, blue: 189/255) //A897BD
    static let cardColor = Color(red: 245/255, green: 240/255, blue: 240/255) //F5F0F0

    static let selectedCard = Color(red: 232/255, green: 221/255, blue: 246/255) //E8DDF6 - الكارد المحددة
    static let offWhiteCapsule = Color(red: 250/255, green: 247/255, blue: 243/255) // الكبسولة لما الكارد محددة
    static let homeActive = Color(red: 168/255, green: 151/255, blue: 189/255) //A897BD - زر الهوم لما يتضغط

    static let stepCircleColor = Color(red: 233/255, green: 228/255, blue: 224/255) // الدائرة الكبيرة بصفحة الستيب
    static let successGreen = Color(red: 199/255, green: 214/255, blue: 172/255) // دائرة صح "Nice work"
}
