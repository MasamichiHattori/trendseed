import SwiftUI

enum MockData {
    static let categories = [
        "すべて", "料理", "フィットネス", "ライフハック", "美容", "ビジネス", "エンタメ"
    ]

    static let videos: [TrendVideo] = [
        TrendVideo(
            id: "mock-ai-banner",
            title: "AIが1分で広告バナーを量産する舞台裏",
            category: "AI",
            countryCode: "US",
            sourceName: "YouTube",
            sourceURLString: "https://www.youtube.com/watch?v=trendseed-ai-banner",
            thumbnailURLString: "https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=900&q=80",
            channelName: "Prompt Sprint",
            viewsText: "320万",
            likesText: "18.4万",
            commentsText: "4,820",
            updatedAt: "2026.06.18",
            thumbnailColors: [.blue, .cyan],
            candidateReason: "AI活用ニーズが高い視聴者に対して、すぐ試せる再現性と危機感のある切り口が同時に入っているためです。",
            growthSummary: "危機感をあおる冒頭の一言で注意を取り、AIで即再現できる期待と実用的なオチで最後まで見せ切っている動画です。",
            structureAnalysis: "冒頭で問題提起を置き、中盤でAIの生成過程を短いカットで連続提示し、最後に再現可能なプロンプトを提示する三段構成です。理解コストが低く、最後まで見る理由が途切れません。",
            hookAnalysis: "冒頭2秒で『デザイナー不要になる?』という強い逆張りワードを提示し、視聴者の危機感を刺激しています。",
            gapAnalysis: "AIで一瞬で作れるという期待に対して、途中で人間の微修正が成果を左右する点を見せ、単純自動化の想像とのズレを作っています。",
            rewardAnalysis: "最後に『このプロンプトを真似すればすぐ再現できる』と具体的な再現可能性を提示し、視聴維持の報酬を明確にしています。",
            retentionAnalysis: "次の工程がすぐ見える短い切り替えを連続させることで、視聴者の期待を落とさずに最後まで引っ張っています。",
            languageDependency: .low,
            prompt: """
            Create a 30-second short-form video script that shows an AI workflow transforming a rough product brief into three high-converting ad banner concepts.
            Start with a contrarian hook, keep each scene under 3 seconds, and end with a reusable prompt.
            """
        ),
        TrendVideo(
            id: "mock-breakfast",
            title: "5ドル朝食が高級ホテル級に見える盛り付け術",
            category: "料理",
            countryCode: "US",
            sourceName: "YouTube",
            sourceURLString: "https://www.youtube.com/watch?v=trendseed-breakfast",
            thumbnailURLString: "https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=900&q=80",
            channelName: "Tiny Plate Lab",
            viewsText: "210万",
            likesText: "12.1万",
            commentsText: "2,940",
            updatedAt: "2026.06.17",
            thumbnailColors: [.orange, .yellow],
            candidateReason: "低価格と高見えの組み合わせが強く、保存したくなる実用性まで含まれているため拡散しやすいです。",
            growthSummary: "安いのに高級に見えるという強い対比がフックになり、誰でもすぐ試せる見た目改善が保存動機になっています。",
            structureAnalysis: "価格の安さを先に見せて期待値を下げたあと、盛り付けの工程を細かく刻んで見せ、最後に完成品でギャップを回収する構造です。",
            hookAnalysis: "低価格と高級感という真逆の要素を同時に提示し、視聴者に『どうやるの?』を瞬時に発生させています。",
            gapAnalysis: "節約レシピだと思わせておいて、実際は盛り付けの見せ方が本題である点にギャップがあります。",
            rewardAnalysis: "真似した瞬間に見栄えが上がる即効性が強い報酬になっており、保存したくなる設計です。",
            retentionAnalysis: "盛り付け前後の差が少しずつ積み上がる構成なので、完成形を早く見たくなる気持ちを維持しています。",
            languageDependency: .medium,
            prompt: """
            Write a visually-driven short video concept that upgrades a cheap breakfast into a cafe-style plate.
            Focus on contrast, plating close-ups, and a satisfying final reveal.
            """
        ),
        TrendVideo(
            id: "mock-posture",
            title: "腹筋より先に姿勢を変えるだけで見た目が変わる",
            category: "フィットネス",
            countryCode: "US",
            sourceName: "YouTube",
            sourceURLString: "https://www.youtube.com/watch?v=trendseed-posture",
            thumbnailURLString: "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=900&q=80",
            channelName: "Body Reset Club",
            viewsText: "480万",
            likesText: "27.6万",
            commentsText: "8,110",
            updatedAt: "2026.06.19",
            thumbnailColors: [.mint, .green],
            candidateReason: "筋トレ不要という意外性が強く、短時間で変化を体感できるので離脱しにくいテーマです。",
            growthSummary: "筋トレ不要という意外性で興味を引き、その場で変化を体感できる即効性が高い視聴維持につながっています。",
            structureAnalysis: "常識を否定する冒頭で引き込み、すぐに姿勢の実演を見せて納得を作り、ビフォーアフターで成果を確信させる流れです。",
            hookAnalysis: "『腹筋しなくていい』という禁止解除型のフックで離脱を防ぎ、共感と驚きを同時に取っています。",
            gapAnalysis: "筋トレ動画だと思わせて姿勢改善へ話をずらすことで、意外性と納得感を両立しています。",
            rewardAnalysis: "その場で姿勢を変えた瞬間に見た目が変わるため、視聴中に成果を疑似体験できます。",
            retentionAnalysis: "視聴中に自分でも試したくなる小さな動作を途中に入れることで、離脱より参加を促しています。",
            languageDependency: .low,
            prompt: """
            Generate a short-form fitness script that reframes body transformation through posture instead of workouts.
            Use a myth-busting hook, one easy demo, and a visual before/after payoff.
            """
        ),
        TrendVideo(
            id: "mock-interview",
            title: "面接で落ちる人の話し方を3秒で直す",
            category: "ビジネス",
            countryCode: "US",
            sourceName: "YouTube",
            sourceURLString: "https://www.youtube.com/watch?v=trendseed-interview",
            thumbnailURLString: "https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=900&q=80",
            channelName: "Career Fastlane",
            viewsText: "167万",
            likesText: "9.3万",
            commentsText: "1,780",
            updatedAt: "2026.06.16",
            thumbnailColors: [.indigo, .purple],
            candidateReason: "就活・転職の不安に直結するうえ、すぐ使える一言改善なので実務層に刺さりやすいです。",
            growthSummary: "面接で落ちたくないという強い不安に直結し、すぐ使える小さな改善策を提示しているので保存価値が高い動画です。",
            structureAnalysis: "最初に失敗リスクを強調し、その後に1つの改善ポイントへ絞って説明し、視聴者が次の面接でそのまま使える形で締めています。",
            hookAnalysis: "就活・転職層の不安を直撃するワードで、最初の一言から自己関連性を高めています。",
            gapAnalysis: "テクニック解説と思わせて、実際には『話す前の間』という見落とされがちな要素を主題にしています。",
            rewardAnalysis: "すぐ試せる上に失敗回避の価値が大きく、保存や共有の理由が強い動画です。",
            retentionAnalysis: "失敗例から改善例への切り替えを短く見せることで、次の一言を確認したい心理を保っています。",
            languageDependency: .high,
            prompt: """
            Build a 35-second career advice short with a high-stakes opening about interview mistakes.
            Teach one subtle speaking habit and end with a repeatable template line.
            """
        ),
        TrendVideo(
            id: "mock-history-map",
            title: "学校で習わない歴史の裏話を1枚の地図で理解する",
            category: "教育",
            countryCode: "US",
            sourceName: "YouTube",
            sourceURLString: "https://www.youtube.com/watch?v=trendseed-history",
            thumbnailURLString: "https://images.unsplash.com/photo-1505664194779-8beaceb93744?auto=format&fit=crop&w=900&q=80",
            channelName: "Map Thread",
            viewsText: "289万",
            likesText: "15.8万",
            commentsText: "3,150",
            updatedAt: "2026.06.15",
            thumbnailColors: [.teal, .blue],
            candidateReason: "難しい内容を1枚の地図に圧縮していて、知的好奇心と手軽さを両立しているため視聴完了率が高まりやすいです。",
            growthSummary: "学校では学ばない知識という知的フックに加え、1枚の地図で理解できる手軽さが最後まで見たくなる理由になっています。",
            structureAnalysis: "知られていない事実を先に示し、地図を軸に背景を順番に読み解いていき、最後に知識の意味づけをして記憶に残す構成です。",
            hookAnalysis: "学校教育で抜け落ちた知識という切り口が、知的好奇心と軽い反骨心を刺激しています。",
            gapAnalysis: "長い歴史説明を想像させながら、実際は1枚の地図だけで理解できる手軽さにギャップがあります。",
            rewardAnalysis: "『人に話したくなる知識』が報酬になっており、コメント欄で議論が生まれやすい構造です。",
            retentionAnalysis: "地図のどこが次に動くかを追いたくなるため、視線の移動そのものが維持要因になっています。",
            languageDependency: .medium,
            prompt: """
            Outline an educational short that explains a hidden historical turning point using one map.
            Keep it visual, surprising, and easy to retell.
            """
        )
    ]

    static let favoriteVideos: [TrendVideo] = [
        videos[0],
        videos[2],
        videos[4]
    ]

    static let freePlanFeatures: [PlanFeature] = [
        PlanFeature(title: "分析結果は1日1件まで閲覧"),
        PlanFeature(title: "一覧と概要の閲覧"),
        PlanFeature(title: "分析結果の詳細前に広告表示")
    ]

    static let premiumPlanFeatures: [PlanFeature] = [
        PlanFeature(title: "分析結果見放題"),
        PlanFeature(title: "分析結果の詳細前に広告なし"),
        PlanFeature(title: "制作プロンプト利用"),
        PlanFeature(title: "今後追加される機能も利用可能")
    ]
}
