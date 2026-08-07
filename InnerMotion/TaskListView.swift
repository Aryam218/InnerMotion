import SwiftUI

struct TaskListView: View {
    @State private var selectedTab = "All"

    let tabs = ["All", "In Progress", "Completed", "Not Started"]
        var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.98, green: 0.96, blue: 0.93)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                
                    
                    Text("My Tasks")
                        .font(.largeTitle)
                        .fontWeight(.regular)
                        .foregroundColor(Color(hex: "#4B2E83"))
                        .offset(y: 30)

                    
                    HStack(spacing: 8) {

                        ForEach(tabs, id: \.self) { tab in

                            Button {
                                withAnimation(.easeInOut) {
                                    selectedTab = tab
                                }
                            } label: {

                                Text(tab)
                                    .font(.system(size: 10))
                                    .foregroundColor(selectedTab == tab
                                        ? Color(red: 117/255, green: 96/255, blue: 142/255)
                                        : .gray
                                    )

                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                
                                                        
                             
                                    .background(
                                        selectedTab == tab
                                        ? Color(red: 123/255, green: 0/255, blue: 255/255).opacity(0.10)
                                        : Color.clear
                                    )
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    .cornerRadius(10)
                            }

                            if tab != tabs.last {
                                Divider()
                                    .frame(height: 20)
                            }
                        }
                    }
                    .padding(8)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(color: .black.opacity(0.1), radius: 8)
                    .padding(.horizontal)
                    
                    
                    .offset(y: 60)

                    if selectedTab == "All" || selectedTab == "In Progress" {
                                            VStack(alignment: .leading, spacing: 8) {
                                                
                                                Text("Study for math test")
                                                    .font(.system(size: 18, weight: .medium))
                                                    .foregroundColor(Color(hex: "4B2A72"))
                                                
                                                Text("May 28")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.gray)
                                                
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(20)
                                            .background(Color(hex: "FFFFFF"))
                                            .cornerRadius(22)
                                            .shadow(color: .black.opacity(0.06), radius: 8)
                                            .padding(.horizontal)
                                            .padding(.top, 90)
                                        }

                           
                                        if selectedTab == "All" {
                                            VStack(alignment: .leading, spacing: 8) {
                                                
                                                Text("STake a shower")
                                                    .font(.system(size: 18, weight: .medium))
                                                    .foregroundColor(Color(hex: "4B2A72"))
                                                
                                                Text("Today")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.gray)
                                                
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(20)
                                            .background(Color(hex: "FFFFFF"))                    .cornerRadius(22)
                                            .shadow(color: .black.opacity(0.06), radius: 8)
                                            .padding(.horizontal)
                                            .padding(.top, -10)
                                            
                                            
                                            
                                            VStack(alignment: .leading, spacing: 8) {
                                                
                                                Text("Clean the room")
                                                    .font(.system(size: 18, weight: .medium))
                                                    .foregroundColor(Color(hex: "4B2A72"))
                                                
                                                Text("May 30")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.gray)
                                                
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(20)
                                            .background(Color.white)
                                            .cornerRadius(22)
                                            .shadow(color: .black.opacity(0.06), radius: 8)
                                            .padding(.horizontal)
                                            .padding(.top, -10)
                                            
                                        }

                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }

                    #Preview {
                        TaskListView()
                    }

