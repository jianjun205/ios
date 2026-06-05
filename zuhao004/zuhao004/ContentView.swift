//
//  ContentView.swift
//  zuhao004
//
//  Created by andy 正道 on 2026/6/5.
//

import SwiftUI
import Combine

// MARK: - 主题与样式辅助
struct ThemeColor {
    static var background: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? 
                UIColor(red: 18/255, green: 19/255, blue: 31/255, alpha: 1) : 
                UIColor(red: 252/255, green: 249/255, blue: 243/255, alpha: 1) // 温暖慵懒奶油黄
        })
    }
    
    static var gridTexture: some View {
        Image("NotebookPaperBackground")
            .resizable(resizingMode: .tile)
            .opacity(0.35)
    }
    
    static var cardBackground: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? 
                UIColor(red: 30/255, green: 33/255, blue: 49/255, alpha: 1) : 
                UIColor.white
        })
    }
    
    static var textPrimary: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? 
                UIColor.white : 
                UIColor(red: 45/255, green: 41/255, blue: 38/255, alpha: 1) // 温和古铜墨黑
        })
    }
    
    static var textSecondary: Color {
        Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? 
                UIColor(red: 180/255, green: 185/255, blue: 210/255, alpha: 1) : 
                UIColor(red: 120/255, green: 115/255, blue: 110/255, alpha: 1)
        })
    }
    
    static var brandAccent: Color {
        Color(red: 245/255, green: 110/255, blue: 125/255) // 温柔浅西桃红
    }
}

// 拓展分类 Emoji
extension EventCategory {
    var cuteEmoji: String {
        switch self {
        case .family: return "🏡"
        case .love: return "💖"
        case .work: return "💼"
        case .birthday: return "🎂"
        case .custom: return "✨"
        }
    }
    
    var cuteGradient: LinearGradient {
        let colors: [Color]
        switch self {
        case .family:
            colors = [Color(red: 224/255, green: 238/255, blue: 255/255), Color(red: 188/255, green: 212/255, blue: 250/255)]
        case .love:
            colors = [Color(red: 255/255, green: 228/255, blue: 232/255), Color(red: 255/255, green: 192/255, blue: 203/255)]
        case .work:
            colors = [Color(red: 226/255, green: 248/255, blue: 242/255), Color(red: 190/255, green: 242/255, blue: 223/255)]
        case .birthday:
            colors = [Color(red: 255/255, green: 245/255, blue: 212/255), Color(red: 255/255, green: 220/255, blue: 145/255)]
        case .custom:
            colors = [Color(red: 244/255, green: 232/255, blue: 255/255), Color(red: 222/255, green: 192/255, blue: 255/255)]
        }
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    struct GreetingMessage {
        let title: String
        let message: String
    }
    
    var greetings: [GreetingMessage] {
        switch self {
        case .family:
            return [
                GreetingMessage(title: "🏡 团圆温情日", message: "炊烟袅袅，家人环绕。今天最温暖的港湾一直为你亮着灯盏。"),
                GreetingMessage(title: "🏡 骨肉情深", message: "岁月的流逝带不走至亲的呼唤，今天，给家里打个最暖的电话吧。"),
                GreetingMessage(title: "🏡 柴米油盐皆是爱", message: "日常的细碎和家人的陪伴，构筑了生命中最牢固的温存印记。"),
                GreetingMessage(title: "🏡 至亲港湾", message: "无论走得多远，家永远是温热的避风坞，今天属于你和最亲近的他们。"),
                GreetingMessage(title: "🏡 天伦乐事", message: "那些默默撑伞的岁月里，家人就是你背后最坚实的温柔屏障。"),
                GreetingMessage(title: "🏡 围炉夜话", message: "哪怕只是简简单单的一餐饭，因为家人的笑脸，今天也变得无比闪耀。"),
                GreetingMessage(title: "🏡 光阴里的牵挂", message: "父母渐白的发丝，孩子牙牙的软语，都在这一刻凝聚成无限慈爱。"),
                GreetingMessage(title: "🏡 静好岁月", message: "愿家中灯火长明，亲人常伴左右。这杯岁月的老茶，越品越暖心。"),
                GreetingMessage(title: "🏡 温情永存", message: "岁月在额头留下痕迹，爱却在心底建起城堡。今天，要拥抱家人哦。"),
                GreetingMessage(title: "🏡 家和万事兴", message: "平淡生活的每一张餐桌前，都流淌着岁月给予我们最无私的馈赠。")
            ]
        case .love:
            return [
                GreetingMessage(title: "💖 喜结良期", message: "大喜日子刚好在今天！赶紧给自己放个假，尽享生活这一秒的温暖。"),
                GreetingMessage(title: "💖 炽热心跳", message: "因为有你的存在，连拂面而过的风都裹挟着草莓味的甜腻气息。"),
                GreetingMessage(title: "💖 专属浪漫", message: "漫步于银河，不如与你共度一个平常的日落。今天，爱意溢出了纸张。"),
                GreetingMessage(title: "💖 相濡以沫", message: "手牵手走过的石子路，在今天化作了岁月中最斑斓的彩色相簿。"),
                GreetingMessage(title: "💖 情书手稿", message: "千言万语，抵不过对视时眼底那抹只属于彼此的璀璨星河。"),
                GreetingMessage(title: "💖 怦然心动", message: "每一次心动的微光，都在今天的纪念薄中，落笔成了永不褪色的红心。"),
                GreetingMessage(title: "💖 岁月有你", message: "世界很吵，但只要看见你的笑靥，耳畔便只剩下诗般的宁静。"),
                GreetingMessage(title: "💖 暮暮朝朝", message: "未来的每一缕清晨日光与夜半星点，我都迫不及待想与你一同拆封。"),
                GreetingMessage(title: "💖 执子之手", message: "没有惊天动地的誓言，仅用温暖的十指相扣，便可抵御一切世间风雪。"),
                GreetingMessage(title: "💖 甜甜的纪念", message: "把与你相遇、相识、相守的所有小细节，揉成今天最柔软的糖果。")
            ]
        case .work:
            return [
                GreetingMessage(title: "💼 进阶里程碑", message: "今天见证了你在逐梦之路上迈出的坚实一步，所有的汗水都有了回音！"),
                GreetingMessage(title: "💼 灵感狂欢", message: "才华在指尖跃动，每一次咬牙坚持，都在今天淬炼成了无价的徽章。"),
                GreetingMessage(title: "💼 蓄势待发", message: "披荆斩棘，不负韶华。今天，给自己一杯香浓咖啡，继续执笔宏图！"),
                GreetingMessage(title: "💼 功不唐捐", message: "那些默默做出的努力都会在某一天破土而出，今天就是你盛开的序曲。"),
                GreetingMessage(title: "💼 职人初心", message: "坚持理想，不被琐碎生活所磨灭。你的专注，就是世界上最酷的才华。"),
                GreetingMessage(title: "💼 点石成金", message: "团队的默契，自我的突破。这一座沉甸甸的奖杯，你当之无愧。"),
                GreetingMessage(title: "💼 逆风翻盘", message: "跨越低谷的人，总能看到更广袤的日出。今天，我们一起高歌猛进！"),
                GreetingMessage(title: "💼 逐光同行", message: "既然胸中藏有璀璨群星，就无惧漫长黑夜。今天，为你的坚韧喝彩。"),
                GreetingMessage(title: "💼 自我迭代", message: "每一次从头开始的勇气，都是通往大师境界路上最耀眼的指南针。"),
                GreetingMessage(title: "💼 匠心独具", message: "精雕细琢每一个像素与字句。今天，请满怀骄傲地写下你的奋斗手记。")
            ]
        case .birthday:
            return [
                GreetingMessage(title: "🎂 岁岁今朝", message: "祝你生日快乐！愿你这一岁，眼里有光，心底有爱，身旁有风，前方有坦途。"),
                GreetingMessage(title: "🎂 璀璨新生", message: "又成长了一岁，请继续肆意生长，不被世俗定义的风吹倒，做最真实的自己！"),
                GreetingMessage(title: "🎂 烛光许愿", message: "闭上双眼，在微微摇曳的烛火中，吹散昨日烦忧，迎接一切不期而遇的惊喜。"),
                GreetingMessage(title: "🎂 满岁礼赞", message: "收集了一年的星光与好运，在今天如期绽放。生日大吉，要天天开心哦！"),
                GreetingMessage(title: "🎂 纯真未泯", message: "愿你出走半生，归来仍是那个吃着小蛋糕、满脸稚气对未来微笑的少年。"),
                GreetingMessage(title: "🎂 生辰之遇", message: "感恩生活给予我们这一场名叫‘生命’的奇遇，今天你就是全世界的焦点。"),
                GreetingMessage(title: "🎂 许我一生明媚", message: "愿生活的所有苦痛都对你绕道而行，而所有的温柔与幸运，都与你环环相扣。"),
                GreetingMessage(title: "🎂 蛋糕上的碎碎念", message: "年年今日，岁岁今朝。吃下这一口甜，下一年保管你运势旺到飞起！"),
                GreetingMessage(title: "🎂 逐梦年华", message: "不负成长，不负自己。每一道年轮，都是你在这个蔚蓝星球上起舞的优美轨迹。"),
                GreetingMessage(title: "🎂 与世界初见", message: "这一天，因为你的啼哭落地而变得与众不同，今天全世界都想对你温柔微笑。")
            ]
        case .custom:
            return [
                GreetingMessage(title: "✨ 时光惊喜匣", message: "生命中所有无法归类的璀璨瞬间，都在今天如烟火般在你的脑海中灿烂盛开！"),
                GreetingMessage(title: "✨ 打卡日常奇迹", message: "不被定义的才是最自由的。今天，让这颗小勺子般的奇迹点燃平凡的一天。"),
                GreetingMessage(title: "✨ 浮生半日闲", message: "偷得浮生半日闲，把那些有趣、无厘头、小确幸的事，庄重地记在今天。"),
                GreetingMessage(title: "✨ 梦幻泡泡", message: "用充满热忱的心去感知周遭，哪怕是不经意的一次偶遇，也是生活的彩色气泡。"),
                GreetingMessage(title: "✨ 星沙拾贝", message: "大海退潮后，你捡起那颗泛着奇异彩光的贝壳。今天，把它锁进我们的木匣中。"),
                GreetingMessage(title: "✨ 自定义好运", message: "给这一天打上一个独特的记号，它既是过去的回声，也是未来奇遇的预告片。"),
                GreetingMessage(title: "✨ 独乐乐亦融融", message: "生活不缺宏大的命题，只缺你嘴边那一抹会微笑的弧度。今天，做个快乐的隐士。"),
                GreetingMessage(title: "✨ 秘密花园", message: "在这里没有社交压力，只有你和这一瞬间。像猫咪一样在阳光下舒展四肢吧。"),
                GreetingMessage(title: "✨ 光合作用", message: "在日常的忙碌和空隙间，接纳温柔的阳光。今天，你要努力地给自己充电哦！"),
                GreetingMessage(title: "✨ 自在如风", message: "不问来路，不忧去程。在这一格里，写下只有你和时光才能看懂的密语。")
            ]
        }
    }
    
    func randomGreeting(forEventId id: UUID) -> GreetingMessage {
        let list = self.greetings
        let index = abs(id.hashValue) % list.count
        return list[index]
    }
}

// MARK: - 去 AI 味的手绘排版组件

// 卡片小节标题：用手绘荧光记号笔竖条代替 emoji 前缀
struct SectionMarker: View {
    let title: String
    var color: Color = ThemeColor.brandAccent
    var size: CGFloat = 15
    
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 4, height: size + 1)
            Text(title)
                .font(.system(size: size, weight: .bold))
                .foregroundColor(ThemeColor.textPrimary)
        }
    }
}

// 页面大标题：标题文字下方手绘高亮涂抹笔触，替代 emoji 装饰
struct HandUnderlineTitle: View {
    let title: String
    var color: Color = ThemeColor.brandAccent
    var size: CGFloat = 26
    
    var body: some View {
        Text(title)
            .font(.system(size: size, weight: .bold))
            .foregroundColor(ThemeColor.textPrimary)
            .background(
                color.opacity(0.18)
                    .frame(height: size * 0.42)
                    .cornerRadius(size * 0.21)
                    .offset(y: size * 0.32)
                , alignment: .bottom
            )
    }
}

struct ContentView: View {
    @EnvironmentObject var store: EventStore
    @State private var selectedTab = 0
    @State private var hasAgreedToPrivacy = UserDefaults.standard.bool(forKey: "hasAgreedToPrivacy")
    @State private var showPrivacyBlockAlert = false
    
    var body: some View {
        ZStack {
            ThemeColor.background.edgesIgnoringSafeArea(.all)
            ThemeColor.gridTexture.edgesIgnoringSafeArea(.all)
            
            if hasAgreedToPrivacy {
                TabView(selection: $selectedTab) {
                    HomeListView()
                        .tabItem {
                            Image(systemName: "hourglass")
                            Text("时光签")
                        }
                        .tag(0)
                    
                    MyCalendarView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("日历簿")
                        }
                        .tag(1)
                    
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gear")
                            Text("手账设")
                        }
                        .tag(2)
                }
            } else {
                PrivacyConsentView(onAgree: {
                    UserDefaults.standard.set(true, forKey: "hasAgreedToPrivacy")
                    withAnimation {
                        hasAgreedToPrivacy = true
                    }
                }, onDisagree: {
                    showPrivacyBlockAlert = true
                })
                .alert(isPresented: $showPrivacyBlockAlert) {
                    Alert(
                        title: Text("温暖时光之约"),
                        message: Text("好朋友，这是一本属于你个人的私密日程表，我们坚持100%全离线物理存储。只有同意了本条款，我们才能替你启动手账哦。"),
                        dismissButton: .default(Text("再看看"))
                    )
                }
            }
        }
    }
}

// MARK: - 辅助：获取分类专属颜色
func getCategoryColor(_ category: EventCategory) -> Color {
    switch category {
    case .family: return Color(red: 74/255, green: 144/255, blue: 226/255)
    case .love: return Color(red: 240/255, green: 98/255, blue: 146/255)
    case .work: return Color(red: 77/255, green: 182/255, blue: 172/255)
    case .birthday: return Color(red: 186/255, green: 104/255, blue: 200/255)
    case .custom: return Color(red: 255/255, green: 167/255, blue: 38/255)
    }
}

// MARK: - 首页：暖色倒计时卡片手账
struct HomeListView: View {
    @EnvironmentObject var store: EventStore
    @State private var searchText = ""
    @State private var selectedCategoryFilter: EventCategory? = nil
    @State private var isShowingAddSheet = false
    
    var filteredEvents: [Event] {
         var list = store.events
         
         if !searchText.isEmpty {
             list = list.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.note.localizedCaseInsensitiveContains(searchText) }
         }
         
         if let filter = selectedCategoryFilter {
             list = list.filter { $0.category == filter }
         }
         
         return list.sorted { (e1, e2) -> Bool in
             let calc1 = e1.daysCalculation()
             let calc2 = e2.daysCalculation()
             
             if calc1.isFuture && !calc2.isFuture {
                 return true
             } else if !calc1.isFuture && calc2.isFuture {
                 return false
             } else {
                 return calc1.days < calc2.days
             }
         }
     }
     
     var body: some View {
         NavigationView {
             ZStack {
                 ThemeColor.background.edgesIgnoringSafeArea(.all)
                 ThemeColor.gridTexture.edgesIgnoringSafeArea(.all)
                 
                 VStack(spacing: 0) {
                     // 自制元气满满的插画式页头
                     VStack(alignment: .leading, spacing: 4) {
                         HStack {
                             HandUnderlineTitle(title: "时光倒计时", size: 26)
                             Spacer()
                             Button(action: {
                                 isShowingAddSheet = true
                             }) {
                                 HStack(spacing: 3) {
                                     Image(systemName: "square.and.pencil")
                                         .font(.system(size: 15))
                                     Text("写手账")
                                         .font(.system(size: 13, weight: .bold))
                                 }
                                 .padding(.horizontal, 12)
                                 .padding(.vertical, 6)
                                 .background(ThemeColor.brandAccent)
                                 .foregroundColor(.white)
                                 .cornerRadius(20)
                                 .shadow(color: ThemeColor.brandAccent.opacity(0.3), radius: 4, x: 0, y: 2)
                             }
                         }
                         
                         Text("碎碎碎的时光，叠成你温柔的心愿卡。")
                             .font(.system(size: 12))
                             .foregroundColor(ThemeColor.textSecondary)
                     }
                     .padding(.horizontal)
                     .padding(.top, 14)
                     .padding(.bottom, 10)
                     
                     // 生动的手绘感搜索栏
                     HStack {
                         HStack {
                             Image(systemName: "magnifyingglass")
                                 .foregroundColor(ThemeColor.textSecondary)
                             TextField("寻觅你记录在册的故事...", text: $searchText)
                                 .font(.system(size: 14))
                                 .foregroundColor(ThemeColor.textPrimary)
                         }
                         .padding(10)
                         .background(ThemeColor.cardBackground)
                         .cornerRadius(14)
                         .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                         
                         if !searchText.isEmpty {
                             Button("取消") {
                                 searchText = ""
                             }
                             .font(.system(size: 14))
                             .foregroundColor(ThemeColor.brandAccent)
                             .padding(.leading, 4)
                         }
                     }
                     .padding(.horizontal)
                     .padding(.bottom, 12)
                     
                     // 软萌彩色糖果检索球/豆荚
                     ScrollView(.horizontal, showsIndicators: false) {
                         HStack(spacing: 8) {
                             Button(action: {
                                 selectedCategoryFilter = nil
                             }) {
                                 Text("全部岁月")
                                     .font(.system(size: 12, weight: .bold))
                                     .padding(.horizontal, 14)
                                     .padding(.vertical, 8)
                                     .background(selectedCategoryFilter == nil ? ThemeColor.textPrimary : ThemeColor.cardBackground)
                                     .foregroundColor(selectedCategoryFilter == nil ? Color(.systemBackground) : ThemeColor.textPrimary)
                                     .cornerRadius(18)
                                     .shadow(color: Color.black.opacity(0.03), radius: 2, y: 1)
                             }
                             
                             ForEach(EventCategory.allCases) { cat in
                                 Button(action: {
                                     selectedCategoryFilter = cat
                                 }) {
                                     HStack(spacing: 4) {
                                         Text(cat.cuteEmoji)
                                         Text(cat == .custom ? "杂货铺" : cat.rawValue)
                                     }
                                     .font(.system(size: 12, weight: .bold))
                                     .padding(.horizontal, 14)
                                     .padding(.vertical, 8)
                                     .background(selectedCategoryFilter == cat ? getCategoryColor(cat) : ThemeColor.cardBackground)
                                     .foregroundColor(selectedCategoryFilter == cat ? .white : ThemeColor.textPrimary)
                                     .cornerRadius(18)
                                     .shadow(color: Color.black.opacity(0.03), radius: 2, y: 1)
                                 }
                             }
                         }
                         .padding(.horizontal)
                         .padding(.bottom, 12)
                     }
                     
                     // 内容展现块 (完全干掉 sterile generic List，采用 ScrollV + 卡片)
                     if filteredEvents.isEmpty {
                         Spacer()
                         VStack(spacing: 16) {
                             Image("CuteIllustrationPlaceholder")
                                 .resizable()
                                 .scaledToFit()
                                 .frame(width: 100, height: 100)
                             Text(searchText.isEmpty ? "还没有在这记下心愿~" : "时光轴上没找到这段记忆")
                                 .font(.system(size: 16, weight: .bold))
                                 .foregroundColor(ThemeColor.textPrimary)
                             Text(searchText.isEmpty ? "快点击右上角“写手账”\n将属于你的本地温存封装起来吧" : "换个小词，也许就能浮现呢~")
                                 .font(.system(size: 13))
                                 .foregroundColor(ThemeColor.textSecondary)
                                 .multilineTextAlignment(.center)
                                 .lineSpacing(4)
                         }
                         .padding(.horizontal)
                         Spacer()
                     } else {
                         ScrollView {
                             VStack(spacing: 14) {
                                 ForEach(filteredEvents) { event in
                                     NavigationLink(destination: EventDetailView(event: event)) {
                                         EventCardView(event: event)
                                     }
                                     .buttonStyle(PlainButtonStyle())
                                 }
                             }
                             .padding(.horizontal)
                             .padding(.top, 4)
                             .padding(.bottom, 30)
                         }
                     }
                 }
             }
             .navigationBarTitle("", displayMode: .inline)
             .navigationBarHidden(true)
             .sheet(isPresented: $isShowingAddSheet) {
                 EventAddEditView()
                     .environmentObject(store)
             }
         }
         .navigationViewStyle(StackNavigationViewStyle())
     }
}

// MARK: - 极具生机活力、去 AI 模板化的排贴手账卡片
struct EventCardView: View {
    let event: Event
    
    var body: some View {
        let calc = event.daysCalculation()
        return HStack(spacing: 12) {
            PolaroidView(
                uiImage: event.imageFileName != nil ? EventStore.shared.loadImage(fileName: event.imageFileName!) : nil,
                emoji: event.category.cuteEmoji,
                themeColor: getCategoryColor(event.category)
            )
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(event.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(ThemeColor.textPrimary)
                        .lineLimit(1)
                    
                    if event.isYearlyRepeat {
                        Text("每年")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(ThemeColor.brandAccent)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(ThemeColor.brandAccent.opacity(0.12))
                            .cornerRadius(6)
                    }
                }
                
                Text(formatDate(event.date))
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(ThemeColor.textSecondary)
                
                if !event.note.isEmpty {
                    Text("“\(event.note)”")
                        .font(.system(size: 11))
                        .italic()
                        .foregroundColor(ThemeColor.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            JournalStamp(days: calc.days, isFuture: calc.isFuture, color: getCategoryColor(event.category))
        }
        .padding(14)
        .background(event.category.cuteGradient)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy / MM / dd"
        return formatter.string(from: date)
    }
}

// MARK: - 独一无二具有质感的小偏心拍立得
struct PolaroidView: View {
    let uiImage: UIImage?
    let emoji: String
    let themeColor: Color
    
    var body: some View {
        VStack(spacing: 2) {
            if let img = uiImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .cornerRadius(6)
                    .clipped()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(themeColor.opacity(0.15))
                        .frame(width: 52, height: 52)
                    Text(emoji)
                        .font(.system(size: 26))
                }
            }
        }
        .padding(5)
        .padding(.bottom, 10)
        .background(Color.white)
        .cornerRadius(4)
        .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1.5)
        .rotationEffect(.degrees(-3))
        .overlay(
            // 使用实体绘制的高质感和纹纸胶带 NotebookTape，彻底打碎白胶带的AI干瘪扁平感
            Image("NotebookTape")
                .resizable()
                .frame(width: 38, height: 16)
                .offset(y: -32)
        )
    }
}

// MARK: - 精致的手账虚线邮票封签 Stamp
struct JournalStamp: View {
    let days: Int
    let isFuture: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 3) {
            if days == 0 {
                Text("TODAY")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.pink)
                    .cornerRadius(4)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 15))
                    .foregroundColor(.pink)
                
                Text("就在今朝")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.pink)
            } else {
                Text(isFuture ? "COMING" : "PAST")
                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(isFuture ? color : Color.gray)
                    .cornerRadius(4)
                
                Text("\(days)")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(isFuture ? Color(red: 45/255, green: 41/255, blue: 38/255) : Color.secondary)
                
                Text(isFuture ? "天后到" : "天已往")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 62, height: 72)
        .background(Color.white.opacity(0.85))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFuture ? color.opacity(0.4) : Color.gray.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
        )
    }
}

// MARK: - 纪念日详情页面
struct EventDetailView: View {
    @EnvironmentObject var store: EventStore
    @Environment(\.presentationMode) var presentationMode
    let event: Event
    
    @State private var isShowingEditSheet = false
    
    var body: some View {
        let calc = event.daysCalculation()
        let catColor = getCategoryColor(event.category)
        
        return ZStack {
            ThemeColor.background.edgesIgnoringSafeArea(.all)
            ThemeColor.gridTexture.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // 页顶撕纸效果卡片
                    VStack(spacing: 16) {
                        HStack {
                            Text(event.category.cuteEmoji)
                                .font(.system(size: 32))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(ThemeColor.textPrimary)
                                Text("备档归类：\(event.displayCategoryName)")
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeColor.textSecondary)
                            }
                            Spacer()
                        }
                        
                        Divider()
                            .background(Color.gray.opacity(0.15))
                        
                        if calc.days == 0 {
                            let greeting = event.category.randomGreeting(forEventId: event.id)
                            VStack(spacing: 12) {
                                Text(greeting.title)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(getCategoryColor(event.category))
                                Text(greeting.message)
                                    .font(.system(size: 13))
                                    .foregroundColor(ThemeColor.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.vertical, 14)
                        } else {
                            VStack(spacing: 6) {
                                Text(calc.isFuture ? "还有" : "已经远去")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(ThemeColor.textSecondary)
                                
                                Text("\(calc.days)")
                                    .font(.system(size: 68, weight: .black, design: .rounded))
                                    .foregroundColor(calc.isFuture ? catColor : .gray)
                                    .shadow(color: calc.isFuture ? catColor.opacity(0.2) : Color.clear, radius: 6, y: 3)
                                
                                Text("个日落晨曦")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(ThemeColor.textSecondary)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                            Text("日期指针: \(formatDate(event.date))")
                        }
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.black.opacity(0.04))
                        .cornerRadius(10)
                        .foregroundColor(ThemeColor.textSecondary)
                    }
                    .padding(20)
                    .background(ThemeColor.cardBackground)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                    .padding(.top, 14)
                    
                    // 写意备注纸 (Torn Paper Note)
                    if !event.note.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("✍️ 心情备忘")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(ThemeColor.textPrimary)
                                Spacer()
                            }
                            Text(event.note)
                                .font(.system(size: 14))
                                .foregroundColor(ThemeColor.textPrimary)
                                .lineSpacing(6)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    ZStack {
                                        Color(red: 255/255, green: 253/255, blue: 233/255) // 浅黄便签纸
                                        VStack {
                                            ForEach(0..<8) { _ in
                                                Divider().background(Color.blue.opacity(0.04))
                                                Spacer()
                                            }
                                        }
                                    }
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 2)
                        }
                        .padding(18)
                        .background(ThemeColor.cardBackground)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
                    }
                    
                    // 物理克隆本地存照 (拍立得写意框)
                    if let imgFileName = event.imageFileName, let img = store.loadImage(fileName: imgFileName) {
                        VStack(spacing: 12) {
                            HStack {
                                Text("📷 独家时光切影")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(ThemeColor.textPrimary)
                                Spacer()
                            }
                            
                            VStack(spacing: 8) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(8)
                                    .padding(10)
                                    .background(Color.white)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4)
                                
                                Text("“记录，是抗拒生命遗忘的最佳仪式”")
                                    .font(.system(size: 11, weight: .light))
                                    .foregroundColor(Color.gray)
                                    .padding(.bottom, 6)
                            }
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .rotationEffect(.degrees(1.5))
                            .padding(.vertical, 8)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(ThemeColor.textSecondary)
                                Text("纯物理沙盒，未加载外部图床、100%安全")
                                    .font(.system(size: 10))
                                    .foregroundColor(ThemeColor.textSecondary)
                            }
                        }
                        .padding(18)
                        .background(ThemeColor.cardBackground)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
                    }
                    
                    // 铃声提醒信息
                    HStack(spacing: 12) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(event.isNotificationEnabled ? .orange : Color.gray.opacity(0.5))
                            .font(.system(size: 20))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.isNotificationEnabled ? "该纪念日将在当日弹出通知" : "本卡片处于静音时光轴")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(ThemeColor.textPrimary)
                            if event.isNotificationEnabled {
                                let offset = event.notificationTimeOffset == 0 ? "事件当天早上 09:00" : "提前 \(event.notificationTimeOffset) 天早上 09:00"
                                Text("系统推送队列已排定: \(offset)")
                                    .font(.system(size: 11))
                                    .foregroundColor(ThemeColor.textSecondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(18)
                    .background(ThemeColor.cardBackground)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
                    
                    // 合而为一的按钮组
                    VStack(spacing: 12) {
                        Button(action: {
                            store.deleteEvent(event)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "trash")
                                Text("丢弃这张时光签")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(18)
                        }
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitle("手账卡明细", displayMode: .inline)
        .navigationBarItems(trailing:
            Button("编辑卡片") {
                isShowingEditSheet = true
            }
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(ThemeColor.brandAccent)
        )
        .sheet(isPresented: $isShowingEditSheet) {
            EventAddEditView(editingEvent: event)
                .environmentObject(store)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 年 MM 月 dd 日"
        return formatter.string(from: date)
    }
}

// MARK: - 纪念日添加与编辑纸张
struct EventAddEditView: View {
    @EnvironmentObject var store: EventStore
    @Environment(\.presentationMode) var presentationMode
    
    var editingEvent: Event? = nil
    
    @State private var title: String
    @State private var date: Date
    @State private var note: String
    @State private var category: EventCategory
    @State private var customCategoryName: String
    @State private var isNotificationEnabled: Bool
    @State private var notificationTimeOffset: Int
    @State private var isYearlyRepeat: Bool
    @State private var selectedImage: UIImage?
    
    @State private var isImagePickerPresented = false
    @State private var showingCustomCategoryGuide = false
    
    init(editingEvent: Event? = nil, initialDate: Date = Date()) {
        self.editingEvent = editingEvent
        if let editing = editingEvent {
            _title = State(initialValue: editing.title)
            _date = State(initialValue: editing.date)
            _note = State(initialValue: editing.note)
            _category = State(initialValue: editing.category)
            _customCategoryName = State(initialValue: editing.customCategoryName ?? "")
            _isNotificationEnabled = State(initialValue: editing.isNotificationEnabled)
            _notificationTimeOffset = State(initialValue: editing.notificationTimeOffset)
            _isYearlyRepeat = State(initialValue: editing.isYearlyRepeat)
            _selectedImage = State(initialValue: nil)
        } else {
            _title = State(initialValue: "")
            _date = State(initialValue: initialDate)
            _note = State(initialValue: "")
            _category = State(initialValue: .family)
            _customCategoryName = State(initialValue: "")
            _isNotificationEnabled = State(initialValue: false)
            _notificationTimeOffset = State(initialValue: 0)
            _isYearlyRepeat = State(initialValue: false)
            _selectedImage = State(initialValue: nil)
        }
    }
    
    var isEditMode: Bool {
        editingEvent != nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColor.background.edgesIgnoringSafeArea(.all)
                ThemeColor.gridTexture.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 1. 卡片一：起名字
                        VStack(alignment: .leading, spacing: 12) {
                            SectionMarker(title: "时光签主题", size: 13)
                            
                            TextField("妈妈生日、恋爱纪念、买猫猫一周年...", text: $title)
                                .font(.system(size: 15))
                                .padding()
                                .background(ThemeColor.background)
                                .cornerRadius(12)
                            
                            DatePicker("设定吉日", selection: $date, displayedComponents: .date)
                                .font(.system(size: 15))
                                .padding(.vertical, 4)
                            
                            Toggle(isOn: $isYearlyRepeat) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("每年循环计时")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(ThemeColor.textPrimary)
                                    Text("开启后它能自动为你转进到下一年度的今日哦")
                                        .font(.system(size: 11))
                                        .foregroundColor(ThemeColor.textSecondary)
                                }
                            }
                        }
                        .padding(18)
                        .background(ThemeColor.cardBackground)
                        .cornerRadius(22)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                        
                        // 2. 卡片二：挑选信封归纳
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📦 分纳封套")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(ThemeColor.textSecondary)
                            
                            Picker("挑选所属类别", selection: $category) {
                                ForEach(EventCategory.allCases) { cat in
                                    Text(cat.cuteEmoji + " " + cat.rawValue).tag(cat)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            if category == .custom {
                                TextField("写个专属的杂货标签 (如：开学/种花)...", text: $customCategoryName)
                                    .padding()
                                    .background(ThemeColor.background)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(18)
                        .background(ThemeColor.cardBackground)
                        .cornerRadius(22)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                        
                        // 3. 卡片三：照片克隆
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📸 独家时光切片 (仅限一张、不连任何云)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(ThemeColor.textSecondary)
                            
                            HStack {
                                if let img = selectedImage {
                                    VStack(spacing: 8) {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(10)
                                            .clipped()
                                        
                                        Button("清除放回") {
                                            selectedImage = nil
                                        }
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.red)
                                    }
                                } else {
                                    Button(action: {
                                        isImagePickerPresented = true
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 24))
                                            Text("贴上记忆快照 (相册贴图)")
                                                .font(.system(size: 12, weight: .bold))
                                        }
                                        .foregroundColor(ThemeColor.brandAccent)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 24)
                                        .background(ThemeColor.background)
                                        .cornerRadius(14)
                                    }
                                }
                            }
                        }
                        .padding(18)
                        .background(ThemeColor.cardBackground)
                        .cornerRadius(22)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                        
                        // 4. 卡片四：闹钟
                        VStack(alignment: .leading, spacing: 12) {
                            SectionMarker(title: "本地到点传书提醒 (全离线)", size: 13)
                            
                            Toggle(isOn: $isNotificationEnabled) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("倒计时到期提醒我")
                                        .font(.system(size: 15))
                                    Text("不依托互联网，纯系统引擎分发安全静谧")
                                        .font(.system(size: 11))
                                        .foregroundColor(ThemeColor.textSecondary)
                                }
                            }
                            
                            if isNotificationEnabled {
                                Picker("何时传书", selection: $notificationTimeOffset) {
                                    Text("当天 早上 09:00 提醒").tag(0)
                                    Text("提前 1 天发出预告").tag(1)
                                    Text("提前 3 天做好筹备").tag(3)
                                    Text("提前一整周呼唤").tag(7)
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(height: 80)
                                .clipped()
                            }
                        }
                        .padding(18)
                        .background(ThemeColor.cardBackground)
                        .cornerRadius(22)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                        
                        // 5. 卡片五：碎碎念念
                        VStack(alignment: .leading, spacing: 12) {
                            Text("💌 拾遗碎语")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(ThemeColor.textSecondary)
                            
                            TextField("有何回忆备注？例如地点、或礼物秘密清单...", text: $note)
                                .font(.system(size: 14))
                                .padding()
                                .background(ThemeColor.background)
                                .cornerRadius(12)
                        }
                        .padding(18)
                        .background(ThemeColor.cardBackground)
                        .cornerRadius(22)
                        .shadow(color: Color.black.opacity(0.03), radius: 5, y: 2)
                    }
                    .padding()
                }
            }
            .navigationBarTitle(isEditMode ? "修补手账时光签" : "新建手账时光签", displayMode: .inline)
            .navigationBarItems(
                leading: Button("撤销") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(ThemeColor.textSecondary),
                trailing: Button("封贴保存") {
                    saveAction()
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(ThemeColor.brandAccent)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $selectedImage)
            }
            .onAppear {
                if let editing = editingEvent {
                    title = editing.title
                    date = editing.date
                    note = editing.note
                    category = editing.category
                    customCategoryName = editing.customCategoryName ?? ""
                    isNotificationEnabled = editing.isNotificationEnabled
                    notificationTimeOffset = editing.notificationTimeOffset
                    isYearlyRepeat = editing.isYearlyRepeat
                    if let imgFile = editing.imageFileName {
                        selectedImage = store.loadImage(fileName: imgFile)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func saveAction() {
        let targetCustomName = category == .custom ? (customCategoryName.isEmpty ? "自定义" : customCategoryName) : nil
        
        if let editing = editingEvent {
            let updated = Event(
                id: editing.id,
                title: title,
                date: date,
                note: note,
                category: category,
                customCategoryName: targetCustomName,
                isNotificationEnabled: isNotificationEnabled,
                notificationTimeOffset: notificationTimeOffset,
                imageFileName: editing.imageFileName,
                isYearlyRepeat: isYearlyRepeat
            )
            
            if !isNotificationEnabled {
                store.cancelNotification(for: editing)
            }
            
            store.updateEvent(updated, image: selectedImage)
        } else {
            let newObj = Event(
                id: UUID(),
                title: title,
                date: date,
                note: note,
                category: category,
                customCategoryName: targetCustomName,
                isNotificationEnabled: isNotificationEnabled,
                notificationTimeOffset: notificationTimeOffset,
                imageFileName: nil,
                isYearlyRepeat: isYearlyRepeat
            )
            
            if isNotificationEnabled {
                store.requestNotificationPermission { granted in }
            }
            
            store.addEvent(newObj, image: selectedImage)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - 纸张插孔式复古日历簿
struct MyCalendarView: View {
    @EnvironmentObject var store: EventStore
    @State private var currentMonth: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var isShowingAddSheet = false
    @State private var showingDetailEvent: Event? = nil
    
    private let calendar = Calendar.current
    private let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
    
    var eventsOnSelectedDate: [Event] {
        return store.events.filter { event in
            if event.isYearlyRepeat {
                let eventComp = calendar.dateComponents([.month, .day], from: event.date)
                let selectedComp = calendar.dateComponents([.month, .day], from: selectedDate)
                return eventComp.month == selectedComp.month && eventComp.day == selectedComp.day
            } else {
                return calendar.isDate(event.date, inSameDayAs: selectedDate)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColor.background.edgesIgnoringSafeArea(.all)
                ThemeColor.gridTexture.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // 日历大标题区
                        VStack(alignment: .leading, spacing: 4) {
                            HandUnderlineTitle(title: "岁月日历簿", size: 24)
                            Text("每一格，都是时光停留过的港湾。")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 14)
                        
                        // 暖心活泼的月份翻页牌
                        HStack {
                            Button(action: { changeMonth(by: -1) }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(ThemeColor.brandAccent)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.04), radius: 2)
                            }
                            
                            Spacer()
                            
                            Text(formatMonthYear(currentMonth))
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(ThemeColor.textPrimary)
                            
                            Spacer()
                            
                            Button(action: { changeMonth(by: 1) }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(ThemeColor.brandAccent)
                                    .frame(width: 36, height: 36)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.04), radius: 2)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(ThemeColor.cardBackground)
                        .cornerRadius(18)
                        .shadow(color: Color.black.opacity(0.02), radius: 3)
                        .padding(.horizontal)
                        
                        // 星期指示表头
                        HStack(spacing: 0) {
                            ForEach(weekdays, id: \.self) { day in
                                Text(day)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(day == "日" || day == "六" ? ThemeColor.brandAccent : ThemeColor.textSecondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                        
                        // 极具质感的日历排片格网 (Paper desktop grid style)
                        VStack(spacing: 12) {
                            ForEach(0..<6, id: \.self) { row in
                                HStack(spacing: 0) {
                                    ForEach(0..<7, id: \.self) { col in
                                        let index = row * 7 + col
                                        let datesList = daysInMonth()
                                        
                                        if index < datesList.count, let date = datesList[index] {
                                            let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                                            let isToday = calendar.isDateInToday(date)
                                            let dayEvents = eventsForDate(date)
                                            
                                            Button(action: { selectedDate = date }) {
                                                VStack(spacing: 4) {
                                                    // 选定高亮效果：手写本圆圈涂鸦质感
                                                    Text("\(calendar.component(.day, from: date))")
                                                        .font(.system(size: 15, weight: isSelected || isToday ? .bold : .medium, design: .rounded))
                                                        .foregroundColor(isSelected ? .white : (isToday ? ThemeColor.brandAccent : ThemeColor.textPrimary))
                                                        .frame(width: 32, height: 32)
                                                        .background(
                                                            ZStack {
                                                                if isSelected {
                                                                    ThemeColor.brandAccent
                                                                } else if isToday {
                                                                    ThemeColor.brandAccent.opacity(0.12)
                                                                } else {
                                                                    Color.clear
                                                                }
                                                            }
                                                        )
                                                        .clipShape(Circle())
                                                    
                                                    // 极其生动可爱的彩底指示点
                                                    HStack(spacing: 3) {
                                                        if !dayEvents.isEmpty {
                                                            ForEach(dayEvents.prefix(3)) { ev in
                                                                Circle()
                                                                    .fill(getCategoryColor(ev.category))
                                                                    .frame(width: 4, height: 4)
                                                            }
                                                        } else {
                                                            Spacer().frame(height: 4)
                                                        }
                                                    }
                                                }
                                                .frame(maxWidth: .infinity)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        } else {
                                            Text("")
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 38)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(14)
                        .background(ThemeColor.cardBackground)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.03), radius: 6, y: 3)
                        .padding(.horizontal)
                        
                        Divider().padding(.horizontal).padding(.vertical, 4)
                        
                        // 下方日记页底当选行程
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 6) {
                                SectionMarker(title: "\(formatShortDate(selectedDate)) 时光事件录", size: 15)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            if eventsOnSelectedDate.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "leaf")
                                        .font(.system(size: 24))
                                        .foregroundColor(ThemeColor.brandAccent.opacity(0.6))
                                    Text("这天平静安宁，时光轴上未有心事。")
                                        .font(.system(size: 12))
                                        .foregroundColor(ThemeColor.textSecondary)
                                    
                                    Button(action: { isShowingAddSheet = true }) {
                                        Text("在此处打卡新签")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(ThemeColor.brandAccent)
                                            .cornerRadius(16)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(ThemeColor.cardBackground)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.015), radius: 4)
                                .padding(.horizontal)
                            } else {
                                ForEach(eventsOnSelectedDate) { ev in
                                    Button(action: { showingDetailEvent = ev }) {
                                        HStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .fill(getCategoryColor(ev.category).opacity(0.12))
                                                    .frame(width: 36, height: 36)
                                                Text(ev.category.cuteEmoji)
                                                    .font(.system(size: 16))
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(ev.title)
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(ThemeColor.textPrimary)
                                                if !ev.note.isEmpty {
                                                    Text(ev.note)
                                                        .font(.system(size: 11))
                                                        .foregroundColor(ThemeColor.textSecondary)
                                                        .lineLimit(1)
                                                }
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(ThemeColor.textSecondary)
                                        }
                                        .padding()
                                        .background(ThemeColor.cardBackground)
                                        .cornerRadius(18)
                                        .shadow(color: Color.black.opacity(0.02), radius: 3, y: 1.5)
                                        .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingAddSheet) {
                EventAddEditView(initialDate: selectedDate)
                    .environmentObject(store)
            }
            .sheet(item: $showingDetailEvent) { ev in
                NavigationView {
                    EventDetailView(event: ev)
                        .environmentObject(store)
                        .navigationBarItems(leading: Button("关闭") {
                            showingDetailEvent = nil
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(ThemeColor.textSecondary))
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func changeMonth(by amount: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: amount, to: currentMonth) {
            currentMonth = newMonth
        }
    }
    
    private func formatMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 年 M 月"
        return formatter.string(from: date)
    }
    
    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M 月 d 日"
        return formatter.string(from: date)
    }
    
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        let startOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        var days: [Date?] = []
        
        for _ in 0..<firstWeekday {
            days.append(nil)
        }
        
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth) else { return days }
        let numberOfDays = range.count
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        while days.count < 42 {
            days.append(nil)
        }
        
        return days
    }
    
    private func eventsForDate(_ date: Date) -> [Event] {
        return store.events.filter { event in
            if event.isYearlyRepeat {
                let evM = calendar.component(.month, from: event.date)
                let evD = calendar.component(.day, from: event.date)
                let dM = calendar.component(.month, from: date)
                let dD = calendar.component(.day, from: date)
                return evM == dM && evD == dD
            } else {
                return calendar.isDate(event.date, inSameDayAs: date)
            }
        }
    }
}

// MARK: - 设置中心
struct SettingsView: View {
    @EnvironmentObject var store: EventStore
    @State private var isShowingPrivacySheet = false
    @State private var isShowingAboutSheet = false
    @State private var showingClearAllAlert = false
    
    // 导入和导出状态管理
    @State private var isShowingExportShareSheet = false
    @State private var exportURL: URL? = nil
    
    @State private var isShowingImportAlert = false
    @State private var isShowingClipboardError = false
    @State private var isShowingImportSuccess = false
    @State private var importMessage = ""
    
    // 深浅色模式手动切换
    @State private var followSystemTheme = true
    @State private var isDarkModeLocal = false
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColor.background.edgesIgnoringSafeArea(.all)
                ThemeColor.gridTexture.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 暖心大标题
                        VStack(alignment: .leading, spacing: 4) {
                            HandUnderlineTitle(title: "下拉配置簿", size: 24)
                            Text("完全离线、全域保密，您的时光锁，只有您自己能开启。")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColor.textSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 14)
                        
                        // 卡片一：通知提醒设置
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                SectionMarker(title: "消息提醒设置", size: 15)
                                Spacer()
                            }
                            
                            Toggle(isOn: $store.isAppWideNotificationEnabled) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("开启全屏倒计铃推送")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(ThemeColor.textPrimary)
                                    Text("如不生效，请检查系统“设置-通知-纪念日”")
                                        .font(.system(size: 10))
                                        .foregroundColor(ThemeColor.textSecondary)
                                }
                            }
                            .accentColor(ThemeColor.brandAccent)
                            
                            Divider().background(Color.black.opacity(0.04))
                            
                            Button(action: { sendNotificationTest() }) {
                                HStack {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 11))
                                    Text("向本机模拟发送一条 5 秒后的测试提醒")
                                        .font(.system(size: 12, weight: .bold))
                                    Spacer()
                                }
                                .foregroundColor(ThemeColor.brandAccent)
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(16)
                        .background(ThemeColor.cardBackground)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.02), radius: 5, y: 2)
                        .padding(.horizontal)
                        
                        // 卡片二：安全数据包管理
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                SectionMarker(title: "安全数据包管理 (纯离线、极保密)", size: 15)
                                Spacer()
                            }
                            
                            Button(action: { doExport() }) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle().fill(Color.orange.opacity(0.12)).frame(width: 32, height: 32)
                                        Image(systemName: "square.and.arrow.up.fill")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.orange)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("手动物理备份导出")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(ThemeColor.textPrimary)
                                        Text("将沙盒中的 events.json 数据包以及照片打包另存")
                                            .font(.system(size: 10))
                                            .foregroundColor(ThemeColor.textSecondary)
                                    }
                                    Spacer()
                                }
                            }
                            
                            Divider().background(Color.black.opacity(0.04))
                            
                            Button(action: { isShowingImportAlert = true }) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle().fill(Color.blue.opacity(0.12)).frame(width: 32, height: 32)
                                        Image(systemName: "square.and.arrow.down.fill")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.blue)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("从剪贴板读取数据合并")
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(ThemeColor.textPrimary)
                                        Text("自动提取剪贴板中的备份数据并融合到当前日历中")
                                            .font(.system(size: 10))
                                            .foregroundColor(ThemeColor.textSecondary)
                                    }
                                    Spacer()
                                }
                            }
                            
                            Divider().background(Color.black.opacity(0.04))
                            
                            Button(action: { showingClearAllAlert = true }) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle().fill(Color.red.opacity(0.12)).frame(width: 32, height: 32)
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.red)
                                    }
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("一键物理粉碎记录")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.red)
                                        Text("彻底擦断全部记录日志与物理图像，不可找回！")
                                            .font(.system(size: 10))
                                            .foregroundColor(.red.opacity(0.8))
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .padding(16)
                        .background(ThemeColor.cardBackground)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.02), radius: 5, y: 2)
                        .padding(.horizontal)
                        
                        // 卡片三：关于工坊
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                SectionMarker(title: "隐私协议条款 & 自律机制", size: 15)
                                Spacer()
                            }
                            
                            Button(action: { isShowingPrivacySheet = true }) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle().fill(Color.blue.opacity(0.12)).frame(width: 32, height: 32)
                                        Image(systemName: "doc.text").font(.system(size: 13)).foregroundColor(.blue)
                                    }
                                    Text("脱网离线物理备份协议详情 (白皮书)")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(ThemeColor.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(ThemeColor.textSecondary)
                                }
                            }
                            
                            Divider().background(Color.black.opacity(0.04))
                            
                            Button(action: { isShowingAboutSheet = true }) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle().fill(Color.purple.opacity(0.12)).frame(width: 32, height: 32)
                                        Image(systemName: "hand.draw").font(.system(size: 13)).foregroundColor(.purple)
                                    }
                                    Text("关于开发者手绘日记工坊")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(ThemeColor.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(ThemeColor.textSecondary)
                                }
                            }
                        }
                        .padding(16)
                        .background(ThemeColor.cardBackground)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.02), radius: 5, y: 2)
                        .padding(.horizontal)
                        
                        Text("纪念工坊一零〇版 / 物理级无损单机箱")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(ThemeColor.textSecondary)
                            .padding(.top, 10)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingPrivacySheet) {
                NavigationView {
                    ZStack {
                        ThemeColor.background.edgesIgnoringSafeArea(.all)
                        ScrollView {
                            PrivacyDocView()
                        }
                    }
                    .navigationBarTitle("隐私与合规规范详情", displayMode: .inline)
                    .navigationBarItems(leading: Button("关闭") {
                        isShowingPrivacySheet = false
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(ThemeColor.textSecondary))
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .sheet(isPresented: $isShowingAboutSheet) {
                NavigationView {
                    ZStack {
                        ThemeColor.background.edgesIgnoringSafeArea(.all)
                        AboutUsView()
                    }
                    .navigationBarTitle("关于纪念工坊", displayMode: .inline)
                    .navigationBarItems(leading: Button("关闭") {
                        isShowingAboutSheet = false
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(ThemeColor.textSecondary))
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .sheet(isPresented: $isShowingExportShareSheet, content: {
                if let url = exportURL {
                    ShareSheet(activityItems: [url])
                }
            })
            .alert(isPresented: $showingClearAllAlert) {
                Alert(
                    title: Text("确定清空全部数据吗？"),
                    message: Text("此操作将永久彻底地抹杀并粉碎您手机里的所有本地纪念日数据日志、备注内容以及导入的物理多重相册照片，无法通过任何云端机制找回，请再次谨慎确认。"),
                    primaryButton: .destructive(Text("永久抹除")) {
                        store.clearAllData()
                    },
                    secondaryButton: .cancel(Text("保留"))
                )
            }
            .alert(isPresented: $isShowingImportAlert) {
                Alert(
                    title: Text("从粘贴板导入备份"),
                    message: Text("点击确定后，本App将对剪贴板的内容进行检测。如果识别到先前导出的数据包密钥，将秒速补充、合并入现有的记录中。"),
                    primaryButton: .default(Text("确认加载")) {
                        tryImportFromClipboard()
                    },
                    secondaryButton: .cancel(Text("退出"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(
            EmptyView()
                .alert(isPresented: $isShowingImportSuccess) {
                    Alert(
                        title: Text("成功"),
                        message: Text(importMessage),
                        dismissButton: .default(Text("好的"))
                    )
                }
        )
        .background(
            EmptyView()
                .alert(isPresented: $isShowingClipboardError) {
                    Alert(
                        title: Text("导入失败"),
                        message: Text("在我们未能从您的剪切板找到合法的、格式正确的本App备份序列化数据，请手动复制您之前备份导出的备份文件文本内容后重新点击。"),
                        dismissButton: .default(Text("明白"))
                    )
                }
        )
    }
    
    // 执行数据导出
    private func doExport() {
        if let file = store.exportEventsToJSON() {
            self.exportURL = file
            self.isShowingExportShareSheet = true
        }
    }
    
    // 执行剪贴板导入
    private func tryImportFromClipboard() {
        if let text = UIPasteboard.general.string, !text.isEmpty {
            // 我们写个容错处理，看是直接是JSON、或者是从文件临时备份导入。
            // 考虑有些用户可能是通过隔空投送把 events.json 导出并作为文本复制了
            guard let jsonData = text.data(using: .utf8) else {
                isShowingClipboardError = true
                return
            }
            
            // 试试解析
            do {
                let imported = try JSONDecoder().decode([Event].self, from: jsonData)
                if imported.isEmpty {
                    isShowingClipboardError = true
                    return
                }
                
                var count = 0
                for event in imported {
                    if !store.events.contains(where: { $0.id == event.id }) {
                        store.events.append(event)
                        count += 1
                    }
                }
                
                store.syncAllNotifications()
                self.importMessage = "已智能识别！成功零失误导入了 \(count) 条纪念日历史归档到本机中！"
                self.isShowingImportSuccess = true
            } catch {
                isShowingClipboardError = true
            }
        } else {
            isShowingClipboardError = true
        }
    }
    
    // 发送一条临时本地测试通知
    private func sendNotificationTest() {
        store.requestNotificationPermission { granted in
            guard granted else { return }
            
            let content = UNMutableNotificationContent()
            content.title = "纪念日模拟测试提醒 🎉"
            content.body = "恭喜，您的系统本地推送授权通路一切正常，未产生任何后台网络交互，100% 物理级私密。"
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "TestLocalNotif", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}

// MARK: - 包装 iOS 13 UIKit 共享
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - 隐私声明卡片视图 (App Store 5.1 专业规避)
struct PrivacyDocView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Group {
                Text("安全与隐私基本准则（白皮书）")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.bottom, 6)
                
                Text("1. 数据完全『脱网离线』存储")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Text("本软件在设计之初就确立了“绝不接触、不存储用户任何文字及图片”的核心理念。一切应用数据、分类属性、配置项、通知延迟，全部通过系统的 Codable 机制固化在您个人的 iPhone 沙盒目录中的 `events.json` 物理文件上。应用甚至未申请网络套接字端口（Network Socket）以及任何联机域名。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Group {
                Text("2. 图片『零批量、全物理离线本地化』机制")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Text("关于相册存图：应用绝无批量网络图或图床服务。您为纪念日分配的背景照片，仅能点击时通过 iOS 控制中心在您手机的「本地相册」中挑选。被选定的照片会被单张克隆（命名为 ID.jpg）存放在沙盒文档下，其他照片绝不会被程序扫描。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Group {
                Text("3. 严格遵循 5.1 规则，不集成追踪 SDK")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Text("我们拒绝在应用内集成目前市场上多见的包括：广告分发、热度埋点、用户设备画、活跃度监控等第三方 SDK (例如友盟、听云、AdMob 等)。没有任何数据共享给第三方商业机构。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Group {
                Text("4. 纯净全功能免费承诺")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Text("本软件的所有功能均完全向用户免费开放，零内购、零广告、零收费门槛。包括无限添加纪念日、自定义分类及其命名、本地私密相册、倒计时到期提醒等，皆为终身免费使用，让您享受最安静、最放心的离线时光记录体验。")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
            }
        }
        .padding()
    }
}

// MARK: - 关于我们视图
struct AboutUsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 20)
            
            Image(systemName: "hourglass")
                .font(.system(size: 72))
                .foregroundColor(.accentColor)
                .padding()
            
            Text("纪念日计时工坊")
                .font(.title)
                .fontWeight(.bold)
            
            Text("最低支持 iOS 13 / 版本 1.0.0")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("我们是一个秉持“化繁为简、数据归还给个人”理念的独立个人硬件与效率工具工坊。")
                Text("本团队誓不在此应用中塞入广告。如果您用着觉得省心，可以购买高级版或者向熟人推荐我们，这就是对无广告、不作恶工具最好的鼓舞和认同！")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
            
            Text("Copyright © 2026 Memorial Workshop. All Rights Reserved.")
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
    }
}

// MARK: - 首次使用知情同意遮罩 UI
struct PrivacyConsentView: View {
    var onAgree: () -> Void
    var onDisagree: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.accentColor)
                        .padding(.top, 40)
                    
                    Text("纪念日倒计时记事薄\n隐私保护与知情同意书")
                        .font(.title)
                        .fontWeight(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("本App专为追求私密、厌恶广告和社交追踪的高阶用户打造。在您体验之前，请务必了解以下知情书：")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        
                    VStack(alignment: .leading, spacing: 15) {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "externaldrive.fill")
                                .font(.system(size: 14))
                                .foregroundColor(ThemeColor.brandAccent)
                                .frame(width: 18)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("没有云端服务器，全部离线存储")
                                    .fontWeight(.bold)
                                Text("您的纪念日标题、备注、分类、图片，只会以加密/结构化形式保存在您的本机固态存储上，软件没有后台网络端口、不产生任何入站/出站连接流量，彻底杜绝数据泄露。")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "shield.fill")
                                .font(.system(size: 14))
                                .foregroundColor(ThemeColor.brandAccent)
                                .frame(width: 18)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("零用户追踪，零广告 SDK")
                                    .fontWeight(.bold)
                                Text("拒绝接入友盟、Firebase、AdMob、Facebook等任何数据埋点或行为画像收集工具。您的隐私，连我们自己都不知道。")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 14))
                                .foregroundColor(ThemeColor.brandAccent)
                                .frame(width: 18)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("相册与通知独立授权")
                                    .fontWeight(.bold)
                                Text("当您添加照片时，系统会弹出相册访问提示，我们仅对单张照片进行拷贝；本地推送（UNNotification）在添加完后由系统引擎分发，绝不包含外部广告营销推送。")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "gift.fill").font(.system(size: 14)).foregroundColor(ThemeColor.brandAccent).frame(width: 18)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("完全免费，无任何内购和广告")
                                    .fontWeight(.bold)
                                Text("我们绝不设置任何付费门槛或隐藏弹窗，所有功能（如无限自定义分类、本地相册等）全部开放，终身完全免费。只为给您提供纯粹、放心的工具。")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .font(.system(size: 13))
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            
            // 底部操作大按钮区
            VStack(spacing: 12) {
                Button(action: {
                    onAgree()
                }) {
                    Text("同意以上条款，开始记录时光")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Button(action: {
                    onDisagree()
                }) {
                    Text("不同意并退出")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 24)
            }
            .padding(.top, 10)
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - 兼容 iOS 13 的 UIKit 相册选择器包装
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                parent.image = selectedImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

