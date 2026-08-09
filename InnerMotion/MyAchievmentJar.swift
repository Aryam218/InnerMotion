import SwiftUI

struct MyAchievmentJar: View {
    @Environment(\.dismiss) private var dismiss

    // لو true: النجمة تسقط بأنيميشن (توصل من StarRewardView)
    // لو false: النجمة تطلع بمكانها مباشرة بدون أنيميشن (توصل من الـ Navbar)
    var animateStarDrop: Bool = false

    @State private var earnedStar = false
    @State private var starCount = 0

    @State private var selectedTab: Int = 2
    @State private var goToMainTab = false

    var body: some View {
        ZStack(alignment: .bottom) {

            ZStack {

                Color(red: 0.98, green: 0.96, blue: 0.93)
                    .ignoresSafeArea()

                VStack {
                    Text("My Achievment Jar")
                        .font(.title)
                        .fontWeight(.regular)
                        .foregroundStyle(Color(red: 55/255, green: 0/255, blue: 138/255))
                        .offset(y: 50)

                    Text("Every task you complete adds a star to your jar")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .offset(y: 45)

                    ZStack {
                        Image("jar2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 400)
                            .offset(y: 50)

                        Image("star")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .offset(y: earnedStar ? 350 : -120)
                            .scaleEffect(earnedStar ? 0.7 : 1)
                            .animation(animateStarDrop ? .easeInOut(duration: 1.5) : nil, value: earnedStar)
                            .offset(y: -100)
                    }
                    .onAppear {
                        if animateStarDrop {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                earnedStar = true
                                starCount = 1
                            }
                        } else {
                            earnedStar = true
                            starCount = 1
                        }
                    }

                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(red: 245/255, green: 240/255, blue: 240/255))
                        .frame(width: 330, height: 80)
                        .shadow(color: .gray.opacity(0.2), radius: 4)
                        .overlay(
                            HStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                    )

                                VStack(alignment: .leading) {
                                    Text("Your stars so far")
                                        .font(.caption)
                                    Text("\(starCount) star")
                                        .font(.headline)
                                }

                                Spacer()

                                Divider()
                                    .frame(height: 45)

                                Text("Keep going—every step brings you closer to your best")
                                    .font(.caption2)
                                    .multilineTextAlignment(.leading)
                                    .frame(width: 95)
                            }
                            .padding(.horizontal)
                        )
                        .offset(y: 50)

                    Spacer()
                }

            }

            // Navbar السفلي (نفس اللي بـ MainTabView)
            CustomTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 28)
                .padding(.bottom, 10)
        }
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
        .onChange(of: selectedTab) { _, _ in
            goToMainTab = true
        }
        .navigationDestination(isPresented: $goToMainTab) {
            MainTabView(initialTab: selectedTab)
        }
    }
}
#Preview {
    NavigationStack {
        MyAchievmentJar()
    }
}
