import SwiftUI

// ملاحظة: كل الألوان معرّفة بملف Colors.swift
// لا تضيفين extension Color بهذا الملف

struct PlanOneTask: View {

    @Environment(\.dismiss) private var dismiss

    @State private var goToFocusOneStep = false

    var body: some View {

        NavigationStack {
        ZStack {

            Color.backgroundColor
                .ignoresSafeArea()

            VStack {

                // Top Bar

                HStack {

                    Button {

                        dismiss()

                    } label: {

                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    .buttonStyle(PressableIconStyle(normalColor: .primaryText, pressedColor: .secondaryButton))

                    Spacer()

                    Button {

                    } label: {

                        Image(systemName: "house")
                            .font(.system(size: 28))
                    }
                    .buttonStyle(PressableIconStyle(normalColor: .primaryText, pressedColor: .secondaryButton))

                }
                .padding(.horizontal,25)
                .padding(.top,15)

                Spacer().frame(height:25)

                // Title

                Text("Your first steps")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundColor(.primaryText)

                Text("Tiny steps to get you moving")
                    .font(.system(size: 17))
                    .foregroundColor(.secondaryText)

                Spacer().frame(height:35)

                // Goal

                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.cardColor)
                    .frame(height:65)
                    .overlay(
                        HStack {

                            Text("Study for math exam")
                                .foregroundColor(.secondaryText)
                                .font(.system(size:21))

                            Spacer()

                        }
                        .padding(.horizontal,20)
                    )
                    .padding(.horizontal)

                Spacer().frame(height:35)

                StepCard(number: "1",
                         text: "Open the lecture slides",
                         highlight: true)

                StepCard(number: "2",
                         text: "Read the first title only")

                StepCard(number: "3",
                         text: "Highlight one line")

                StepCard(number: "4",
                         text: "Take a short pause")

                Spacer(minLength: 100)

                Button {

                    goToFocusOneStep = true

                } label: {

                    Text("Start First Step")
                        .font(.system(size:28))
                        .frame(maxWidth: .infinity)
                        .frame(height:60)

                }
                .buttonStyle(PressableCapsuleStyle(fillColor: .primaryButton))
                .padding(.horizontal,35)
                .navigationDestination(isPresented: $goToFocusOneStep) {
                    FocusOneStep()
                }

                Button {

                } label: {

                    Text("Make it Easier")
                        .font(.system(size:28))
                        .frame(maxWidth:.infinity)
                        .frame(height:60)

                }
                .buttonStyle(PressableCapsuleStyle(fillColor: .secondaryButton))
                .padding(.horizontal,35)
                .padding(.bottom,35)

            }

        }
        .toolbar(.hidden, for: .navigationBar)

        }

    }
}


struct StepCard: View {

    var number: String
    var text: String
    var highlight = false

    var body: some View {

        RoundedRectangle(cornerRadius:18)
            .fill(highlight ? Color.selectedCard : Color.cardColor)
            .frame(height:70)
            .overlay(

                HStack(spacing:18){

                    Circle()
                        .stroke(Color.secondaryText,lineWidth:2)
                        .frame(width:38,height:38)
                        .overlay(
                            Text(number)
                                .foregroundColor(.secondaryText)
                        )

                    Text(text)
                        .foregroundColor(.secondaryText)
                        .font(.system(size:20))

                    Spacer()

                }
                .padding(.horizontal,18)

            )
            .padding(.horizontal)

    }

}


#Preview {
    PlanOneTask()
}
