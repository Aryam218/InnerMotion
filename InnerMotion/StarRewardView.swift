import SwiftUI

struct StarRewardView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.93)
                .ignoresSafeArea()

            VStack {

                // Top Bar (نفس تنسيق باقي الصفحات)
                HStack {

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    .buttonStyle(PressableIconStyle(normalColor: .primaryText, pressedColor: .secondaryButton))

                    Spacer()

                    NavigationLink {
                        MainTabView()
                    } label: {
                        Image(systemName: "house")
                            .font(.system(size: 28))
                    }
                    .buttonStyle(PressableIconStyle(normalColor: .primaryText, pressedColor: .secondaryButton))
                }
                .padding(.horizontal, 25)
                .padding(.top, 15)

                Spacer()
            }

            Image("star")
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
                .offset(y: -210)

            VStack {
                Text("You earned a star!")
                    .font(.title)
                    .fontWeight(.regular)
                    .foregroundStyle(Color(red: 55/255, green: 0/255, blue: 138/255))
                    .offset(y: 5)

                Text("Your task has been completed")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .offset(y: 5)

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 245/255, green: 240/255, blue: 240/255))
                    .frame(width: 320, height: 80)
                    .shadow(color: .gray.opacity(0.2), radius: 4)
                    .overlay(

                        HStack(spacing: 15) {

                            Circle()
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title2)
                                )

                            Text("1 Star added to your\nAchievement Jar")
                                .font(.subheadline)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.black)

                            Spacer()
                        }
                            .padding(.horizontal)
                    )              .offset(y: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            NavigationLink(destination: MyAchievmentJar(animateStarDrop: true)) {
                Text("View My Achievement Jar")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 28)
                    .background(
                        Color(red: 126/255, green: 106/255, blue: 158/255)
                    )
                    .cornerRadius(25)
            }
            .padding(.top, 690)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
#Preview {
    NavigationStack {
        StarRewardView()
    }
}
