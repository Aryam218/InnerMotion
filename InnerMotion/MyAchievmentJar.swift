import SwiftUI
import SwiftData

struct MyAchievmentJar: View {

    @Environment(\.dismiss) private var dismiss

    // قراءة المهام الحقيقية المحفوظة في SwiftData
    @Query private var userTasks: [UserTask]

    // لو true: النجمة تسقط بأنيميشن (توصل من StarRewardView)
    // لو false: النجمة تطلع بمكانها مباشرة بدون أنيميشن (توصل من الـ Navbar)
    var animateStarDrop: Bool = false

    @State private var earnedStar = false

    @State private var selectedTab: Int = 2
    @State private var goToMainTab = false

    // عدد المهام المكتملة = عدد النجوم الحقيقي
    private var starCount: Int {
        userTasks.filter {
            $0.status == "Completed"
        }.count
    }

    // النص يتغير بين star و stars
    private var starCountText: String {
        if starCount == 1 {
            return "1 star"
        } else {
            return "\(starCount) stars"
        }
    }

    var body: some View {

        ZStack(alignment: .bottom) {

            ZStack {

                Color(
                    red: 0.98,
                    green: 0.96,
                    blue: 0.93
                )
                .ignoresSafeArea()

                VStack {

                    Text("My Achievment Jar")
                        .font(.title)
                        .fontWeight(.regular)
                        .foregroundStyle(
                            Color(
                                red: 55/255,
                                green: 0/255,
                                blue: 138/255
                            )
                        )
                        .offset(y: 50)

                    Text(
                        "Every task you complete adds a star to your jar"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .offset(y: 45)

                    // MARK: - Jar

                    ZStack {

                        Image("jar2")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: 400,
                                height: 400
                            )
                            .offset(y: 50)

                        // نظهر النجمة فقط إذا المستخدم عنده إنجاز واحد أو أكثر
                        if starCount > 0 {

                            Image("star")
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: 300,
                                    height: 300
                                )
                                .offset(
                                    y: earnedStar
                                    ? 350
                                    : -120
                                )
                                .scaleEffect(
                                    earnedStar
                                    ? 0.7
                                    : 1
                                )
                                .animation(
                                    animateStarDrop
                                    ? .easeInOut(duration: 1.5)
                                    : nil,
                                    value: earnedStar
                                )
                                .offset(y: -100)
                        }
                    }

                    // MARK: - Star Animation

                    .onAppear {

                        // إذا ما عنده ولا نجمة
                        // ما نحتاج نسوي animation
                        guard starCount > 0 else {
                            return
                        }

                        if animateStarDrop {

                            // إذا جاي من StarRewardView
                            // نخلي النجمة تنزل داخل الجرة
                            earnedStar = false

                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 1
                            ) {
                                earnedStar = true
                            }

                        } else {

                            // إذا دخل من الـ Navbar
                            // تظهر النجمة بمكانها مباشرة
                            earnedStar = true
                        }
                    }

                    // MARK: - Stars Count Card

                    RoundedRectangle(
                        cornerRadius: 15
                    )
                    .fill(
                        Color(
                            red: 245/255,
                            green: 240/255,
                            blue: 240/255
                        )
                    )
                    .frame(
                        width: 330,
                        height: 80
                    )
                    .shadow(
                        color: .gray.opacity(0.2),
                        radius: 4
                    )
                    .overlay(

                        HStack {

                            Circle()
                                .fill(
                                    Color.gray.opacity(0.15)
                                )
                                .frame(
                                    width: 50,
                                    height: 50
                                )
                                .overlay(

                                    Image(
                                        systemName: "star.fill"
                                    )
                                    .foregroundColor(.yellow)
                                )

                            VStack(
                                alignment: .leading
                            ) {

                                Text("Your stars so far")
                                    .font(.caption)

                                Text(starCountText)
                                    .font(.headline)
                            }

                            Spacer()

                            Divider()
                                .frame(height: 45)

                            Text(
                                "Keep going—every step brings you closer to your best"
                            )
                            .font(.caption2)
                            .multilineTextAlignment(
                                .leading
                            )
                            .frame(width: 95)
                        }
                        .padding(.horizontal)
                    )
                    .offset(y: 50)

                    Spacer()
                }
            }

            // MARK: - Bottom Navbar

            CustomTabBar(
                selectedTab: $selectedTab
            )
            .padding(.horizontal, 28)
            .padding(.bottom, 10)
        }

        .ignoresSafeArea(.keyboard)

        .navigationBarBackButtonHidden(true)

        // إذا المستخدم ضغط أي Tab
        .onChange(of: selectedTab) { _, _ in
            goToMainTab = true
        }

        .navigationDestination(
            isPresented: $goToMainTab
        ) {
            MainTabView(
                initialTab: selectedTab
            )
        }
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {
        MyAchievmentJar()
    }
    .modelContainer(
        for: [
            UserTask.self,
            DayPlan.self,
            PlannedTask.self,
            TaskStep.self
        ],
        inMemory: true
    )
}
