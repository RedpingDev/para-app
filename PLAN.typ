// ─────────────────────────────────────────────
// PARA Management System - Flutter App 계획서
// Typst Document  |  v1.0  |  2026-02-18
// ─────────────────────────────────────────────

// ── 페이지 & 폰트 설정 ──────────────────────
#set page(
  paper: "a4",
  margin: (top: 2.5cm, bottom: 2.5cm, left: 2cm, right: 2cm),
  header: context {
    if counter(page).get().first() > 1 [
      #set text(9pt, fill: luma(140))
      PARA Management System — Flutter App 계획서
      #h(1fr) v1.0
      #line(length: 100%, stroke: 0.5pt + luma(200))
    ]
  },
  footer: context {
    set text(9pt, fill: luma(140))
    h(1fr)
    counter(page).display("1 / 1", both: true)
    h(1fr)
  },
)

#set text(font: ("Malgun Gothic"), size: 10.5pt, lang: "ko")
#set par(leading: 0.8em, justify: true)
#set heading(numbering: "1.1")

#show heading.where(level: 1): it => {
  v(1.2em)
  block(
    width: 100%,
    inset: (bottom: 8pt),
    stroke: (bottom: 2pt + rgb("#6C5CE7")),
    text(16pt, weight: "bold", fill: rgb("#2D3436"), it.body),
  )
  v(0.4em)
}

#show heading.where(level: 2): it => {
  v(0.8em)
  text(13pt, weight: "bold", fill: rgb("#6C5CE7"), it.body)
  v(0.3em)
}

#show heading.where(level: 3): it => {
  v(0.5em)
  text(11pt, weight: "bold", fill: rgb("#636E72"), it.body)
  v(0.2em)
}

// ── 유틸리티 함수 ──────────────────────────
#let accent = rgb("#6C5CE7")
#let proj-color = rgb("#00B894")
#let area-color = rgb("#0984E3")
#let res-color  = rgb("#FDCB6E")
#let arch-color = rgb("#636E72")
#let bg-dark    = rgb("#1A1A2E")

#let badge(body, color: accent) = {
  box(
    fill: color.lighten(85%),
    stroke: 0.5pt + color,
    radius: 4pt,
    inset: (x: 6pt, y: 3pt),
    text(8pt, weight: "bold", fill: color, body),
  )
}

#let note-box(body, title: "NOTE", color: accent) = {
  block(
    width: 100%,
    fill: color.lighten(92%),
    stroke: (left: 3pt + color),
    radius: (right: 4pt),
    inset: 12pt,
    [
      #text(9pt, weight: "bold", fill: color, title) \
      #body
    ],
  )
}

#let check(done: false, body) = {
  if done {
    [☑ #text(fill: luma(120), strike(body))]
  } else {
    [☐ #body]
  }
}

// ═══════════════════════════════════════════
//  표지 (Cover Page)
// ═══════════════════════════════════════════

#align(center + horizon)[
  #block(width: 80%)[
    #v(2cm)
    #text(12pt, fill: luma(120), tracking: 4pt, weight: "bold")[FLUTTER APPLICATION]
    #v(0.5cm)
    #line(length: 40%, stroke: 2pt + accent)
    #v(0.8cm)
    #text(32pt, weight: "bold", fill: rgb("#2D3436"))[PARA]
    #v(0.2cm)
    #text(14pt, fill: luma(80))[Management System]
    #v(1cm)
    #text(11pt, fill: luma(100))[
      생각을 정리하고, 행동을 이끌어내는\
      *두 번째 뇌 (Second Brain)*
    ]
    #v(1.5cm)

    #grid(
      columns: (1fr, 1fr),
      gutter: 12pt,
      align(center, badge("Projects", color: proj-color)),
      align(center, badge("Areas", color: area-color)),
      align(center, badge("Resources", color: res-color)),
      align(center, badge("Archive", color: arch-color)),
    )

    #v(2cm)
    #line(length: 30%, stroke: 1pt + luma(200))
    #v(0.5cm)
    #text(9pt, fill: luma(140))[
      문서 버전: v1.0 \
      작성일: 2026년 2월 18일 \
      상태: #badge("계획 단계", color: rgb("#E17055"))
    ]
  ]
]

#pagebreak()

// ═══════════════════════════════════════════
//  목차
// ═══════════════════════════════════════════
#outline(
  title: [목차],
  indent: 1.5em,
  depth: 3,
)

#pagebreak()

// ═══════════════════════════════════════════
//  1. 프로젝트 개요
// ═══════════════════════════════════════════
= 프로젝트 개요 (Project Overview)

== PARA란?

Tiago Forte가 고안한 *디지털 정보 관리 시스템*으로, 모든 정보를 4가지 카테고리로 분류합니다.

#table(
  columns: (auto, 1fr, 1fr),
  stroke: 0.5pt + luma(200),
  fill: (col, row) => if row == 0 { accent.lighten(85%) } else { none },
  align: (col, _) => if col == 0 { center } else { left },
  inset: 10pt,
  table.header(
    [*카테고리*], [*설명*], [*특성*],
  ),
  badge("Projects", color: proj-color),
  [명확한 목표와 기한이 있는 단기 노력],
  [시작일/마감일, 진행률, 할일 목록],

  badge("Areas", color: area-color),
  [지속적으로 유지해야 하는 책임 영역],
  [건강, 재정, 커리어 등 지속적 관리],

  badge("Resources", color: res-color),
  [관심 있는 주제나 참고 자료],
  [태그, 북마크, 메모, 링크],

  badge("Archive", color: arch-color),
  [비활성화된 항목들의 저장소],
  [완료된 프로젝트, 더 이상 관리 안 하는 영역],
)

== 앱 비전

#note-box(
  title: "VISION",
  color: accent,
  text(11pt)[_"생각을 정리하고, 행동을 이끌어내는 두 번째 뇌 (Second Brain)"_],
)

#v(0.5em)
*핵심 가치:*

- *심플하지만 강력한* — 복잡하지 않으면서 필요한 기능은 모두 제공
- *빠른 입력* — 떠오르는 생각을 즉시 캡처
- *유연한 이동* — 항목 간 카테고리 전환이 자유로움
- *아름다운 UI* — 다크/라이트 테마, 모던한 디자인

== 타겟 플랫폼

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(200),
  inset: 8pt,
  fill: (_, row) => if row == 0 { luma(245) } else { none },
  [*우선순위*], [*플랫폼*],
  [1차], [Windows Desktop (Flutter Desktop)],
  [2차 확장], [Android / iOS (Flutter Mobile)],
  [3차 확장], [Web (Flutter Web)],
)

#pagebreak()

// ═══════════════════════════════════════════
//  2. 핵심 기능
// ═══════════════════════════════════════════
= 핵심 기능 (Core Features)

== MVP (Minimum Viable Product) — Phase 1

=== PARA 카테고리 관리

- 4개 카테고리(P/A/R/A) 대시보드
- 각 카테고리 내 항목 CRUD (생성/읽기/수정/삭제)
- 항목 간 카테고리 이동 (드래그 앤 드롭 또는 메뉴)
- 아카이브 자동 제안 (오래된 항목)

=== Project (프로젝트) 기능

- 프로젝트 생성 (제목, 설명, 시작일, 마감일)
- 하위 태스크 목록 (체크리스트)
- 진행률 자동 계산 (완료된 태스크 / 전체 태스크)
- 상태 관리: #badge("진행중", color: proj-color) #badge("대기중", color: res-color) #badge("완료", color: area-color) #badge("보관됨", color: arch-color)
- 마감일 임박 알림

=== Area (영역) 기능

- 영역 생성 (제목, 설명, 아이콘)
- 관련 프로젝트 연결
- 영역별 메모/노트 작성
- 유지 기준(Standard) 설정 (예: "매주 운동 3회")

=== Resource (자료) 기능

- 자료 생성 (제목, 내용, 태그)
- 태그 기반 분류
- 마크다운 메모 지원
- URL 링크 저장 및 프리뷰

=== Archive (보관함) 기능

- 보관된 항목 목록
- 보관 날짜 기록
- 복원 기능 (보관함 → 원래 카테고리)
- 영구 삭제 (확인 후)

=== 검색 & 필터

- 전역 검색 (모든 카테고리에서 검색)
- 태그 필터링
- 날짜 범위 필터
- 상태별 필터


== Enhanced Features — Phase 2

#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  note-box(title: "대시보드 & 통계", color: accent)[
    - 오늘의 요약
    - 주간/월간 활동 히트맵
    - 카테고리별 항목 수 차트
    - 최근 활동 타임라인
  ],
  note-box(title: "항목 간 연결 (Linking)", color: area-color)[
    - 프로젝트 ↔ 영역 연결
    - 프로젝트 ↔ 자료 연결
    - 양방향 링크 (Backlinks)
    - 연결 그래프 시각화
  ],
  note-box(title: "Quick Capture (빠른 입력)", color: proj-color)[
    - 시스템 트레이 아이콘
    - 글로벌 단축키로 빠른 메모
    - Inbox (분류 전 임시 저장소)
    - 나중에 적절한 카테고리로 분류
  ],
  note-box(title: "커스터마이징", color: res-color)[
    - 다크/라이트 테마
    - 커스텀 컬러 팔레트
    - 아이콘 커스터마이징
    - 레이아웃 (그리드/리스트/카드)
  ],
)


== Advanced Features — Phase 3

- *동기화 & 백업* — 로컬 JSON/SQLite 백업, Google Drive / OneDrive 연동, 내보내기/가져오기
- *첨부파일 지원* — 이미지·파일 첨부, 스크린샷 캡처 후 바로 첨부
- *스마트 기능* — 주간 리뷰(Weekly Review) 알림, 아카이브 제안, 태그 추천, 검색어 자동완성

#pagebreak()

// ═══════════════════════════════════════════
//  3. 기술 스택
// ═══════════════════════════════════════════
= 기술 스택 (Tech Stack)

== Frontend

#table(
  columns: (auto, 1fr, auto),
  stroke: 0.5pt + luma(200),
  fill: (_, row) => if row == 0 { accent.lighten(85%) } else if calc.odd(row) { luma(248) } else { none },
  inset: 8pt,
  table.header([*영역*], [*기술*], [*비고*]),
  [Framework], [Flutter 3.x (Stable)], [],
  [State Mgmt], [Riverpod 2.x], [추천],
  [Routing], [GoRouter], [],
  [UI], [Material 3 (Material You)], [],
  [Animation], [Flutter Animate / Lottie], [],
  [Icons], [Material Icons + Lucide], [],
  [Fonts], [Pretendard (한글), Inter (영문)], [Google Fonts],
)

== 데이터 저장

#grid(
  columns: (1fr, 1fr),
  gutter: 12pt,
  note-box(title: "로컬 저장소 (Phase 1 — 오프라인 우선)", color: proj-color)[
    - *SQLite* (drift 패키지) — 구조화된 데이터
    - *SharedPreferences* — 앱 설정
    - *파일 시스템* — 첨부파일 저장
  ],
  note-box(title: "클라우드 동기화 (Phase 3 — 선택적)", color: area-color)[
    - Supabase 또는 Firebase
    - Google Drive API
  ],
)

== 주요 패키지

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^2.0.0
  riverpod_annotation: ^2.0.0

  # Database
  drift: ^2.0.0             # SQLite ORM
  sqlite3_flutter_libs:      # SQLite 라이브러리

  # Routing
  go_router: ^14.0.0

  # UI / UX
  flutter_animate: ^4.0.0   # 애니메이션
  google_fonts: ^6.0.0      # 폰트
  fl_chart: ^0.70.0         # 차트
  flutter_markdown: ^0.7.0  # 마크다운 렌더링

  # Utilities
  uuid: ^4.0.0              # 고유 ID 생성
  intl: ^0.19.0             # 날짜/시간 포맷
  url_launcher: ^6.0.0      # URL 열기
  path_provider: ^2.0.0     # 파일 경로

  # Windows 전용
  window_manager: ^0.4.0    # 윈도우 크기 관리
  system_tray: ^2.0.0       # 시스템 트레이
  hotkey_manager: ^0.2.0    # 글로벌 단축키
```

#pagebreak()

// ═══════════════════════════════════════════
//  4. 아키텍처
// ═══════════════════════════════════════════
= 아키텍처 (Architecture)

== 프로젝트 구조

```
lib/
├── main.dart                     # 앱 진입점
├── app.dart                      # MaterialApp 설정
├── core/                         # 핵심 공통 모듈
│   ├── constants/                #   색상, 크기, 문자열
│   ├── theme/                    #   다크/라이트 테마
│   ├── router/                   #   GoRouter 설정
│   ├── utils/                    #   유틸리티 함수
│   └── extensions/               #   확장 메서드
├── data/                         # 데이터 레이어
│   ├── database/                 #   Drift DB, Tables, DAOs
│   ├── models/                   #   데이터 모델
│   └── repositories/             #   리포지토리 패턴
├── providers/                    # Riverpod 프로바이더
├── features/                     # 기능별 화면
│   ├── dashboard/                #   대시보드 (홈)
│   ├── projects/                 #   프로젝트 관리
│   ├── areas/                    #   영역 관리
│   ├── resources/                #   자료 관리
│   ├── archive/                  #   보관함
│   ├── search/                   #   전역 검색
│   ├── inbox/                    #   빠른 입력
│   └── settings/                 #   앱 설정
└── shared/                       # 공유 위젯 & 레이아웃
```

== 아키텍처 레이어

#figure(
  table(
    columns: (auto, 1fr),
    stroke: 0.5pt + luma(200),
    fill: (_, row) => {
      let colors = (accent.lighten(85%), proj-color.lighten(85%), area-color.lighten(85%), res-color.lighten(85%))
      colors.at(row)
    },
    inset: 12pt,
    align: (center, left),
    [*UI Layer*],
    [Dashboard Screen, Projects Screen, Areas Screen, Resources Screen, ...],
    [*Provider Layer*],
    [State Notifiers / AsyncNotifiers / Providers (Riverpod)],
    [*Repository Layer*],
    [Repositories — 데이터 소스 추상화, 비즈니스 로직 처리],
    [*Data Layer*],
    [Drift DB (SQLite)  ·  SharedPreferences (설정)  ·  File System (첨부파일)],
  ),
  caption: [4-Layer Architecture],
)

#pagebreak()

// ═══════════════════════════════════════════
//  5. 데이터 모델
// ═══════════════════════════════════════════
= 데이터 모델 (Data Models)

== ERD (Entity Relationship)

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    stroke: 0.5pt + luma(200),
    fill: (col, row) => if row == 0 { 
      (proj-color.lighten(85%), area-color.lighten(85%), res-color.lighten(85%)).at(col)
    } else { none },
    inset: 8pt,
    align: left,
    [*Projects*], [*Areas*], [*Resources*],
    [
      `id` (PK) \
      `title` \
      `description` \
      `status` \
      `area_id` (FK) \
      `start_date` \
      `due_date` \
      `progress` \
      `created_at` \
      `updated_at` \
      `archived_at`
    ],
    [
      `id` (PK) \
      `title` \
      `description` \
      `icon` \
      `standard` \
      `created_at` \
      `updated_at` \
      `archived_at`
    ],
    [
      `id` (PK) \
      `title` \
      `content` (MD) \
      `url` \
      `item_type` \
      `created_at` \
      `updated_at` \
      `archived_at`
    ],
  ),
  caption: [주요 엔티티],
)

#v(0.8em)

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 12pt,
  figure(
    table(
      columns: (1fr,),
      stroke: 0.5pt + luma(200),
      fill: (_, row) => if row == 0 { luma(240) } else { none },
      inset: 8pt,
      [*Tasks*],
      [`id` (PK) \ `project_id` (FK) \ `title` \ `is_completed` \ `order_index` \ `created_at`],
    ),
    caption: [Tasks],
  ),
  figure(
    table(
      columns: (1fr,),
      stroke: 0.5pt + luma(200),
      fill: (_, row) => if row == 0 { luma(240) } else { none },
      inset: 8pt,
      [*Tags / Item_Tags*],
      [`id` (PK) \ `name` \ `color` \ `created_at` \ \ `item_id` · `item_type` · `tag_id`],
    ),
    caption: [Tags & Junction],
  ),
  figure(
    table(
      columns: (1fr,),
      stroke: 0.5pt + luma(200),
      fill: (_, row) => if row == 0 { luma(240) } else { none },
      inset: 8pt,
      [*Links*],
      [`id` (PK) \ `from_id` \ `from_type` \ `to_id` \ `to_type` \ `created_at`],
    ),
    caption: [Links],
  ),
)

== 모델 클래스 예시

```dart
class Project {
  final String id;
  final String title;
  final String? description;
  final ProjectStatus status;
  final String? areaId;
  final DateTime? startDate;
  final DateTime? dueDate;
  final double progress;       // 0.0 ~ 1.0
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;
  final List<Task> tasks;
  final List<Tag> tags;
}

enum ProjectStatus {
  active,     // 진행중
  onHold,     // 대기중
  completed,  // 완료
  archived,   // 보관됨
}
```

#pagebreak()

// ═══════════════════════════════════════════
//  6. UI/UX 설계
// ═══════════════════════════════════════════
= UI/UX 설계 (Design Concept)

== 디자인 컨셉

- *스타일*: Glassmorphism + Material 3
- *다크 모드 기본* (라이트 모드 전환 가능)

== 색상 팔레트

#grid(
  columns: (1fr,) * 7,
  gutter: 4pt,
  ..(
    ("Primary", accent),
    ("Projects", proj-color),
    ("Areas", area-color),
    ("Resources", res-color),
    ("Archive", arch-color),
    ("BG Dark", bg-dark),
    ("Surface", rgb("#16213E")),
  ).map(((name, color)) => {
    block(
      width: 100%,
      radius: 6pt,
      clip: true,
      stroke: 0.5pt + luma(200),
      [
        #block(width: 100%, height: 28pt, fill: color)
        #align(center, block(inset: 4pt, text(7pt, [
          *#name* \
          #text(fill: luma(120), raw(color.to-hex()))
        ])))
      ],
    )
  }),
)

== 전체 레이아웃 (Desktop)

```
┌─────────────────────────────────────────────────────┐
│  PARA System                 🔍 검색...    ⚙  🌙   │
├────────┬────────────────────────────────────────────┤
│        │                                            │
│  📊   │  대시보드 / 컨텐츠 영역                      │
│ 대시보드│                                            │
│        │  ┌────────┐ ┌────────┐ ┌────────┐ ┌──────┐│
│  📁   │  │Projects│ │ Areas  │ │Resource│ │Archiv││
│ 프로젝트│  │   12   │ │   5    │ │   23   │ │   8  ││
│        │  └────────┘ └────────┘ └────────┘ └──────┘│
│  🏠   │                                            │
│ 영역   │  ── 최근 활동 ──────────────────────        │
│        │  │ ✅ Task 완료: "API 설계 문서 작성" │      │
│  📚   │  │ 📝 새 메모: "Flutter 아키텍처"    │      │
│ 자료   │  ─────────────────────────────────────      │
│        │                                            │
│  🗃   │  ── 임박한 마감일 ──────────────────         │
│ 보관함 │  │ ⚠ PARA App MVP (D-3)             │      │
│        │  │ 📅 블로그 포스트 (D-7)            │      │
│  📥   │  ─────────────────────────────────────      │
│ 인박스  │                                            │
│        │                                            │
│  ⚙   │                                            │
│ 설정   │                                            │
├────────┴────────────────────────────────────────────┤
│  Quick Capture: Ctrl+Shift+N                        │
└─────────────────────────────────────────────────────┘
```

== 인터랙션 & 애니메이션

- 카드 호버 시 약간의 lift 효과 (elevation 변화)
- 카테고리 전환 시 슬라이드 트랜지션
- 체크박스 완료 시 confetti/pulse 애니메이션
- 드래그 앤 드롭으로 카테고리 간 항목 이동
- 검색 시 실시간 하이라이트

== 네비게이션 패턴

#table(
  columns: (auto, 1fr),
  stroke: 0.5pt + luma(200),
  inset: 8pt,
  fill: (_, row) => if row == 0 { luma(245) } else { none },
  [*플랫폼*], [*패턴*],
  [Desktop], [NavigationRail (좌측 사이드바)],
  [Mobile], [BottomNavigationBar (하단 탭)],
  [반응형], [화면 크기에 따라 자동 전환],
)

#pagebreak()

// ═══════════════════════════════════════════
//  7. 개발 로드맵
// ═══════════════════════════════════════════
= 개발 로드맵 (Development Roadmap)

== Phase 1: Foundation #h(0.5em) #badge("1~2주", color: proj-color)

#grid(
  columns: (1fr, 1fr),
  gutter: 16pt,
  [
    === Week 1 — 프로젝트 셋업 & 기본 구조
    #check(done: false)[Flutter 프로젝트 생성]
    #check(done: false)[패키지 설치 및 설정]
    #check(done: false)[폴더 구조 셋업]
    #check(done: false)[테마 시스템 구축 (다크/라이트)]
    #check(done: false)[라우팅 설정 (GoRouter)]
    #check(done: false)[메인 레이아웃 (NavigationRail + Content)]
    #check(done: false)[SQLite 데이터베이스 스키마 정의]
  ],
  [
    === Week 2 — 핵심 CRUD
    #check(done: false)[Project CRUD (생성/읽기/수정/삭제)]
    #check(done: false)[Area CRUD]
    #check(done: false)[Resource CRUD]
    #check(done: false)[Archive 기능 (이동/복원)]
    #check(done: false)[Task 체크리스트 (프로젝트 하위)]
    #check(done: false)[기본 검색 기능]
  ],
)

== Phase 2: Enhancement #h(0.5em) #badge("3~4주", color: area-color)

#grid(
  columns: (1fr, 1fr),
  gutter: 16pt,
  [
    === Week 3 — UI 고도화
    #check(done: false)[대시보드 화면 구현]
    #check(done: false)[카드 뷰 / 리스트 뷰 전환]
    #check(done: false)[애니메이션 추가]
    #check(done: false)[태그 시스템 구현]
    #check(done: false)[마크다운 에디터 (Resources)]
    #check(done: false)[진행률 시각화]
  ],
  [
    === Week 4 — 연결 & 통계
    #check(done: false)[항목 간 링크 기능]
    #check(done: false)[통계 차트 (fl\_chart)]
    #check(done: false)[활동 타임라인]
    #check(done: false)[마감일 알림]
    #check(done: false)[Inbox / Quick Capture]
  ],
)

== Phase 3: Polish #h(0.5em) #badge("5~6주", color: res-color)

#grid(
  columns: (1fr, 1fr),
  gutter: 16pt,
  [
    === Week 5 — 데스크탑 최적화
    #check(done: false)[시스템 트레이 아이콘]
    #check(done: false)[글로벌 단축키]
    #check(done: false)[윈도우 크기 관리]
    #check(done: false)[키보드 단축키 전체 구현]
    #check(done: false)[성능 최적화]
  ],
  [
    === Week 6 — 완성도
    #check(done: false)[데이터 내보내기/가져오기]
    #check(done: false)[백업/복원 기능]
    #check(done: false)[온보딩 화면]
    #check(done: false)[에러 핸들링 강화]
    #check(done: false)[테스트 작성]
  ],
)

#pagebreak()

// ═══════════════════════════════════════════
//  8. 고려사항 & 아이디어
// ═══════════════════════════════════════════
= 고려사항 & 아이디어

== 차별화 포인트

#table(
  columns: (auto, auto, 1fr),
  stroke: 0.5pt + luma(200),
  fill: (_, row) => if row == 0 { accent.lighten(85%) } else if calc.odd(row) { luma(248) } else { none },
  inset: 8pt,
  table.header([*\#*], [*기능*], [*설명*]),
  [1], [Weekly Review 도우미], [매주 일요일 알림 → 각 프로젝트 리뷰 프롬프트],
  [2], [시간 추적 연동], [프로젝트별 소요 시간 타이머],
  [3], [템플릿 시스템], [자주 만드는 프로젝트 유형을 템플릿으로 저장],
  [4], [Zettelkasten 하이브리드], [Resource에 양방향 링크 → 지식 그래프],
  [5], [AI 분류 제안], [제목/내용 기반으로 카테고리 자동 추천 (로컬 ML)],
  [6], [뽀모도로 연동], [프로젝트/태스크에 뽀모도로 타이머 내장],
)

== 주의사항

#note-box(title: "주의사항", color: rgb("#D63031"))[
  - *오프라인 우선* — 인터넷 없이도 완벽하게 동작해야 함
  - *데이터 안전* — 로컬 데이터 손실 방지를 위한 자동 백업
  - *성능* — 항목이 수백\~수천 개여도 빠르게 동작
  - *마이그레이션* — DB 스키마 변경 시 기존 데이터 보존
  - *접근성* — 키보드만으로 모든 기능 사용 가능
]

== 향후 확장 가능성

- *플러그인 시스템* — 사용자가 기능 확장 가능
- *Notion/Obsidian 연동* — 데이터 가져오기/내보내기
- *GitHub Issues 연동* — 개발 프로젝트 동기화
- *캘린더 뷰* — 프로젝트/마감일을 캘린더로 시각화
- *모바일 위젯* — Android/iOS 홈 화면 위젯

// ═══════════════════════════════════════════
//  9. 개발 시작 전 체크리스트
// ═══════════════════════════════════════════
= 개발 시작 전 체크리스트

#block(
  width: 100%,
  fill: luma(248),
  radius: 8pt,
  inset: 16pt,
  stroke: 0.5pt + luma(220),
  [
    #check(done: false)[Flutter SDK 설치 확인 (최신 Stable)]
    #check(done: false)[Windows Desktop 개발 환경 설정]
    #check(done: false)[디자인 시안 확정 (Figma 등)]
    #check(done: false)[Git 저장소 초기화]
    #check(done: false)[CI/CD 파이프라인 설정 (선택)]
    #check(done: false)[코딩 컨벤션 문서화]
  ],
)

#v(2em)
#align(center)[
  #line(length: 30%, stroke: 1pt + luma(200))
  #v(0.5em)
  #text(9pt, fill: luma(140))[
    문서 작성일: 2026-02-18 · 버전: v1.0 · 상태: 계획 단계
  ]
]
