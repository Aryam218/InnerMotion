import SwiftUI
import SwiftData

struct MyAchievmentJar: View {

    @Query private var userTasks: [UserTask]

    // true إذا الشاشة جاية من StarRewardView
    // false إذا جاية من Navbar
    var animateStarDrop: Bool = false

    @State private var selectedTab: Int = 2
    @State private var goToMainTab = false

    // MARK: - Star Count

    private var starCount: Int {
        userTasks.filter {
            $0.status == "Completed"
        }.count
    }

    private var starCountText: String {
        starCount == 1
        ? "1 star"
        : "\(starCount) stars"
    }

    // MARK: - Star Images

    private let starImages = [
        "star",
        "STAR1",
        "STAR2",
        "STAR3"
    ]

    // MARK: - Body

    var body: some View {

        ZStack(alignment: .bottom) {

            ZStack {

                // MARK: Background

                Color(
                    red: 0.98,
                    green: 0.96,
                    blue: 0.93
                )
                .ignoresSafeArea()

                VStack {

                    // MARK: Title

                    Text("My Achievment Jar")
                        .font(.title)
                        .fontWeight(.regular)
                        .foregroundStyle(
                            Color(
                                red: 55 / 255,
                                green: 0 / 255,
                                blue: 138 / 255
                            )
                        )
                        .offset(y: 50)

                    Text(
                        "Every task you complete adds a star to your jar"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .offset(y: 45)

                    // MARK: Jar

                    ZStack {

                        // -----------------------------------------
                        // الجرة
                        // -----------------------------------------

                        Image("jar2")
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: 400,
                                height: 400
                            )
                            .offset(y: 50)

                        // -----------------------------------------
                        // النجوم
                        // -----------------------------------------

                        ForEach(
                            0..<starCount,
                            id: \.self
                        ) { index in

                            JarStarView(
                                imageName:
                                    starImages[
                                        index % starImages.count
                                    ],

                                position:
                                    starPosition(
                                        for: index
                                    ),

                                size:
                                    starSize,

                                // فقط آخر نجمة تسوي Animation
                                shouldAnimate:
                                    animateStarDrop &&
                                    index == starCount - 1
                            )
                            .id("jar-star-\(index)")
                        }
                    }
                    .frame(
                        width: 400,
                        height: 400
                    )

                    // MARK: Stars Count Card

                    RoundedRectangle(
                        cornerRadius: 15
                    )
                    .fill(
                        Color(
                            red: 245 / 255,
                            green: 240 / 255,
                            blue: 240 / 255
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
                    .overlay {

                        HStack {

                            Circle()
                                .fill(
                                    Color.gray.opacity(0.15)
                                )
                                .frame(
                                    width: 50,
                                    height: 50
                                )
                                .overlay {

                                    Image(
                                        systemName: "star.fill"
                                    )
                                    .foregroundColor(.yellow)
                                }

                            VStack(
                                alignment: .leading
                            ) {

                                Text(
                                    "Your stars so far"
                                )
                                .font(.caption)

                                Text(
                                    starCountText
                                )
                                .font(.headline)
                            }

                            Spacer()

                            Divider()
                                .frame(height: 45)

                            Text(
                                "Keep going—every step brings you closer to your best"
                            )
                            .font(.caption2)
                            .multilineTextAlignment(.leading)
                            .frame(width: 95)
                        }
                        .padding(.horizontal)
                    }
                    .offset(y: 50)

                    Spacer()
                }
            }

            // MARK: Bottom Navbar

            CustomTabBar(
                selectedTab: $selectedTab
            )
            .padding(.horizontal, 28)
            .padding(.bottom, 10)
        }

        .ignoresSafeArea(.keyboard)

        .navigationBarBackButtonHidden(true)

        // MARK: Navigation

        .onChange(
            of: selectedTab
        ) { _, _ in

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

    // =============================================================
    // MARK: - STAR SIZE
    // =============================================================

    private var starSize: CGFloat {

        if starCount == 1 {
            return 320
        }

        if starCount <= 3 {
            return 190
        }

        if starCount <= 6 {
            return 170
        }

        if starCount <= 10 {
            return 155
        }

        if starCount <= 15 {
            return 140
        }

        return 120
    }

    // =============================================================
    // MARK: - STAR POSITIONS
    // =============================================================

    private func starPosition(
        for index: Int
    ) -> CGPoint {

        // =================================================
        // نجمة واحدة
        // =================================================

        if starCount == 1 {

            return CGPoint(
                x: 200,
                y: 355
            )
        }

        // =================================================
        // نجمتين
        // =================================================

        if starCount == 2 {

            let positions = [

                CGPoint(
                    x: 160,
                    y: 355
                ),

                CGPoint(
                    x: 240,
                    y: 355
                )
            ]

            return positions[
                index % positions.count
            ]
        }

        // =================================================
        // 3 نجوم
        // =================================================

        if starCount == 3 {

            let positions = [

                CGPoint(
                    x: 145,
                    y: 360
                ),

                CGPoint(
                    x: 200,
                    y: 365
                ),

                CGPoint(
                    x: 255,
                    y: 360
                )
            ]

            return positions[
                index % positions.count
            ]
        }

        // =================================================
        // أكثر من 3 نجوم
        // =================================================

        let positions: [CGPoint] = [

            // =============================================
            // الصف الأول - القاع
            // =============================================

            CGPoint(
                x: 135,
                y: 365
            ),

            CGPoint(
                x: 170,
                y: 370
            ),

            CGPoint(
                x: 205,
                y: 372
            ),

            CGPoint(
                x: 240,
                y: 370
            ),

            CGPoint(
                x: 270,
                y: 365
            ),

            // =============================================
            // الصف الثاني
            // =============================================

            CGPoint(
                x: 150,
                y: 335
            ),

            CGPoint(
                x: 185,
                y: 340
            ),

            CGPoint(
                x: 220,
                y: 340
            ),

            CGPoint(
                x: 250,
                y: 335
            ),

            // =============================================
            // الصف الثالث
            // =============================================

            CGPoint(
                x: 160,
                y: 305
            ),

            CGPoint(
                x: 195,
                y: 310
            ),

            CGPoint(
                x: 230,
                y: 310
            ),

            CGPoint(
                x: 255,
                y: 305
            ),

            // =============================================
            // الصف الرابع
            // =============================================

            CGPoint(
                x: 175,
                y: 275
            ),

            CGPoint(
                x: 210,
                y: 280
            ),

            CGPoint(
                x: 240,
                y: 275
            ),

            // =============================================
            // الصف الخامس
            // =============================================

            CGPoint(
                x: 185,
                y: 245
            ),

            CGPoint(
                x: 220,
                y: 245
            ),

            // =============================================
            // الصف الأخير
            // =============================================

            CGPoint(
                x: 200,
                y: 215
            )
        ]

        return positions[
            index % positions.count
        ]
    }
}


// =============================================================
// MARK: - JAR STAR VIEW
// =============================================================

struct JarStarView: View {

    let imageName: String
    let position: CGPoint
    let size: CGFloat

    // true = هذه النجمة الجديدة
    // false = نجمة قديمة

    let shouldAnimate: Bool

    @State private var isAnimating = false

    var body: some View {

        Image(imageName)
            .resizable()
            .scaledToFit()

            .frame(
                width: size,
                height: size
            )

            // -----------------------------------------
            // المكان النهائي
            // -----------------------------------------

            .position(
                x: position.x,
                y: position.y
            )

            // -----------------------------------------
            // حركة النجمة الجديدة
            // -----------------------------------------

            .offset(
                y:
                    shouldAnimate && !isAnimating
                    ? -350
                    : 0
            )

            .scaleEffect(
                shouldAnimate && !isAnimating
                ? 1.08
                : 1
            )

            // -----------------------------------------
            // Animation
            // -----------------------------------------

            .onAppear {

                guard shouldAnimate else {
                    return
                }

                // نبدأ من فوق

                isAnimating = false

                // نعطي SwiftUI فرصة يرسم
                // النجمة أولاً في مكان البداية

                DispatchQueue.main.async {

                    withAnimation(
                        .spring(
                            response: 0.8,
                            dampingFraction: 0.72
                        )
                    ) {

                        isAnimating = true
                    }
                }
            }
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {

        MyAchievmentJar(
            animateStarDrop: true
        )
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
