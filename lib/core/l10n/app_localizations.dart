/// Simple localization system for ICanNote.
/// Supports English and Korean.
class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(String code) => AppLocalizations(code);

  Map<String, String> get _strings =>
      languageCode == 'ko' ? _ko : _en;

  String get(String key) => _strings[key] ?? key;

  // Common
  String get appName => get('app_name');
  String get cancel => get('cancel');
  String get ok => get('ok');
  String get save => get('save');
  String get delete_ => get('delete');
  String get close => get('close');
  String get done => get('done');
  String get create => get('create');
  String get join => get('join');

  // Menu
  String get lecture => get('lecture');
  String get savePrint => get('save_print');
  String get page => get('page');
  String get insert => get('insert');
  String get screenBackground => get('screen_background');
  String get soundVideo => get('sound_video');
  String get settings => get('settings');
  String get help => get('help');
  String get login => get('login');
  String get signOut => get('sign_out');
  String get collaborate => get('collaborate');

  // Lecture
  String get newLecture => get('new_lecture');
  String get openLectureFile => get('open_lecture_file');
  String get addTextbook => get('add_textbook');
  String get closeLecture => get('close_lecture');
  String get saveAs => get('save_as');
  String get saveAsPdf => get('save_as_pdf');
  String get saveAsImage => get('save_as_image');
  String get print_ => get('print');
  String get sendByEmail => get('send_by_email');

  // Tools
  String get pen => get('pen');
  String get highlighter => get('highlighter');
  String get eraser => get('eraser');
  String get selection => get('selection');
  String get text => get('text');
  String get shapes => get('shapes');
  String get line => get('line');
  String get pan => get('pan');
  String get laserPointer => get('laser_pointer');
  String get sticker => get('sticker');

  // Actions
  String get undo => get('undo');
  String get redo => get('redo');
  String get copy => get('copy');
  String get paste => get('paste');
  String get selectAll => get('select_all');
  String get clearAll => get('clear_all');
  String get bringForward => get('bring_forward');
  String get sendBackward => get('send_backward');
  String get addPage => get('add_page');
  String get deletePage => get('delete_page');

  // Collaboration
  String get createRoom => get('create_room');
  String get joinRoom => get('join_room');
  String get leaveRoom => get('leave_room');
  String get closeRoom => get('close_room');
  String get participants => get('participants');
  String get liveSession => get('live_session');

  // Dashboard
  String get myLectures => get('my_lectures');
  String get openFile => get('open_file');
  String get noLectures => get('no_lectures');

  // Settings
  String get appearance => get('appearance');
  String get theme => get('theme');
  String get language => get('language');
  String get keyboardShortcuts => get('keyboard_shortcuts');
  String get autoSave => get('auto_save');
  String get cursorStyle => get('cursor_style');

  // Subscription
  String get subscription => get('subscription');
  String get currentPlan => get('current_plan');
  String get upgrade => get('upgrade');
  String get manage => get('manage');

  // English strings
  static const Map<String, String> _en = {
    'app_name': 'ICanNote',
    'cancel': 'Cancel',
    'ok': 'OK',
    'save': 'Save',
    'delete': 'Delete',
    'close': 'Close',
    'done': 'Done',
    'create': 'Create',
    'join': 'Join',
    'lecture': 'Lecture',
    'save_print': 'Save/Print',
    'page': 'Page',
    'insert': 'Insert',
    'screen_background': 'Screen/Background',
    'sound_video': 'Sound/Video',
    'settings': 'Settings',
    'help': 'Help',
    'login': 'Login',
    'sign_out': 'Sign Out',
    'collaborate': 'Collaborate',
    'new_lecture': 'New Lecture',
    'open_lecture_file': 'Open Lecture File',
    'add_textbook': 'Add Textbook File',
    'close_lecture': 'Close Lecture',
    'save_as': 'Save As...',
    'save_as_pdf': 'Save as PDF',
    'save_as_image': 'Save as Image',
    'print': 'Print',
    'send_by_email': 'Send by Email',
    'pen': 'Pen',
    'highlighter': 'Highlighter',
    'eraser': 'Eraser',
    'selection': 'Selection',
    'text': 'Text',
    'shapes': 'Shapes',
    'line': 'Line',
    'pan': 'Pan',
    'laser_pointer': 'Laser Pointer',
    'sticker': 'Sticker',
    'undo': 'Undo',
    'redo': 'Redo',
    'copy': 'Copy',
    'paste': 'Paste',
    'select_all': 'Select All',
    'clear_all': 'Clear All',
    'bring_forward': 'Bring Forward',
    'send_backward': 'Send Backward',
    'add_page': 'Add Page',
    'delete_page': 'Delete Page',
    'create_room': 'Create Room',
    'join_room': 'Join Room',
    'leave_room': 'Leave Room',
    'close_room': 'Close Room',
    'participants': 'Participants',
    'live_session': 'Live Session',
    'my_lectures': 'My Lectures',
    'open_file': 'Open File',
    'no_lectures': 'No lectures yet',
    'appearance': 'Appearance',
    'theme': 'Theme',
    'language': 'Language',
    'keyboard_shortcuts': 'Keyboard Shortcuts',
    'auto_save': 'Auto-Save',
    'cursor_style': 'Cursor Style',
    'restore_deleted_page': 'Restore Deleted Page',
    'save_with_protection': 'Save with Protection',
    'about': 'About ICanNote',
    'subscription': 'Subscription',
    'current_plan': 'Current Plan',
    'upgrade': 'Upgrade',
    'manage': 'Manage',
  };

  // Korean strings
  static const Map<String, String> _ko = {
    'app_name': 'ICanNote',
    'cancel': '취소',
    'ok': '확인',
    'save': '저장',
    'delete': '삭제',
    'close': '닫기',
    'done': '완료',
    'create': '생성',
    'join': '참여',
    'lecture': '강의',
    'save_print': '저장/인쇄',
    'page': '페이지',
    'insert': '삽입',
    'screen_background': '화면/배경',
    'sound_video': '소리/동영상',
    'settings': '설정',
    'help': '도움말',
    'login': '로그인',
    'sign_out': '로그아웃',
    'collaborate': '협업',
    'new_lecture': '새 강의',
    'open_lecture_file': '강의 파일 열기',
    'add_textbook': '교재 파일 추가',
    'close_lecture': '강의 닫기',
    'save_as': '다른 이름으로 저장...',
    'save_as_pdf': 'PDF로 저장',
    'save_as_image': '이미지로 저장',
    'print': '인쇄',
    'send_by_email': '이메일로 보내기',
    'pen': '펜',
    'highlighter': '형광펜',
    'eraser': '지우개',
    'selection': '선택',
    'text': '텍스트',
    'shapes': '도형',
    'line': '직선',
    'pan': '이동',
    'laser_pointer': '레이저 포인터',
    'sticker': '스티커',
    'undo': '실행 취소',
    'redo': '다시 실행',
    'copy': '복사',
    'paste': '붙여넣기',
    'select_all': '전체 선택',
    'clear_all': '전체 삭제',
    'bring_forward': '앞으로 가져오기',
    'send_backward': '뒤로 보내기',
    'add_page': '페이지 추가',
    'delete_page': '페이지 삭제',
    'create_room': '방 만들기',
    'join_room': '방 참여',
    'leave_room': '방 나가기',
    'close_room': '방 닫기',
    'participants': '참가자',
    'live_session': '실시간 세션',
    'my_lectures': '내 강의',
    'open_file': '파일 열기',
    'no_lectures': '강의가 아직 없습니다',
    'appearance': '외관',
    'theme': '테마',
    'language': '언어',
    'keyboard_shortcuts': '키보드 단축키',
    'auto_save': '자동 저장',
    'cursor_style': '커서 스타일',
    'restore_deleted_page': '삭제된 페이지 복원',
    'save_with_protection': '보호 저장',
    'about': 'ICanNote 정보',
    'subscription': '구독',
    'current_plan': '현재 플랜',
    'upgrade': '업그레이드',
    'manage': '관리',
  };
}
