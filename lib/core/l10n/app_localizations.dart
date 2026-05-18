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
  String get dashboard => get('dashboard');
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

  // Insert menu
  String get insertImage => get('insert_image');
  String get insertText => get('insert_text');
  String get insertShape => get('insert_shape');
  String get insertLine => get('insert_line');
  String get insertSticker => get('insert_sticker');

  // Screen/Background
  String get backgroundColor => get('background_color');
  String get backgroundPattern => get('background_pattern');
  String get bgWhite => get('bg_white');
  String get bgLightYellow => get('bg_light_yellow');
  String get bgLightGreen => get('bg_light_green');
  String get bgLightBlue => get('bg_light_blue');
  String get bgLightPurple => get('bg_light_purple');
  String get bgLightCoral => get('bg_light_coral');
  String get bgDark => get('bg_dark');
  String get bgBlack => get('bg_black');
  String get patternGrid => get('pattern_grid');
  String get patternRuled => get('pattern_ruled');
  String get patternDots => get('pattern_dots');
  String get patternNone => get('pattern_none');

  // Sound/Video
  String get insertSoundVideo => get('insert_sound_video');
  String get videoUrl => get('video_url');
  String get audioUrl => get('audio_url');
  String get pasteUrlHint => get('paste_url_hint');

  // Bottom toolbar
  String get invertColors => get('invert_colors');
  String get screenCapture => get('screen_capture');
  String get autoAlphabet => get('auto_alphabet');
  String get autoNumber => get('auto_number');
  String get zoomIn => get('zoom_in');
  String get zoomOut => get('zoom_out');
  String get library => get('library');
  String get graph => get('graph');
  String get record => get('record');
  String get stopRecording => get('stop_recording');

  // Right toolbar
  String get textOptions => get('text_options');
  String get fontSize => get('font_size');
  String get bold => get('bold');
  String get italic => get('italic');
  String get freeDraw => get('free_draw');
  String get curve => get('curve');
  String get rectangle => get('rectangle');
  String get circle => get('circle');
  String get polygon => get('polygon');
  String get triangle => get('triangle');
  String get autoShape => get('auto_shape');
  String get select => get('select');
  String get rotate => get('rotate');
  String get detailEraser => get('detail_eraser');

  // Export/Print
  String get exportSuccess => get('export_success');
  String get exportCancelled => get('export_cancelled');
  String get noLectureToExport => get('no_lecture_to_export');
  String get lectureSaved => get('lecture_saved');
  String get saveCancelled => get('save_cancelled');

  // About
  String get aboutTitle => get('about_title');
  String get version => get('version');

  // New Lecture Dialog
  String get newLectureSettings => get('new_lecture_settings');
  String get pageWidth => get('page_width');
  String get pageHeight => get('page_height');
  String get orientation => get('orientation');
  String get landscape => get('landscape');
  String get portrait => get('portrait');
  String get apply => get('apply');
  String get useDefaults => get('use_defaults');

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
    'dashboard': 'Dashboard',
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
    // Insert menu
    'insert_image': 'Insert Image',
    'insert_text': 'Insert Text',
    'insert_shape': 'Insert Shape',
    'insert_line': 'Insert Line',
    'insert_sticker': 'Insert Sticker',
    // Screen/Background
    'background_color': 'Background Color',
    'background_pattern': 'Background Pattern',
    'bg_white': 'White',
    'bg_light_yellow': 'Light Yellow',
    'bg_light_green': 'Light Green',
    'bg_light_blue': 'Light Blue',
    'bg_light_purple': 'Light Purple',
    'bg_light_coral': 'Light Coral',
    'bg_dark': 'Dark',
    'bg_black': 'Black',
    'pattern_grid': 'Grid',
    'pattern_ruled': 'Ruled Lines',
    'pattern_dots': 'Dot Grid',
    'pattern_none': 'None (Plain)',
    // Sound/Video
    'insert_sound_video': 'Insert Sound/Video',
    'video_url': 'Video URL (YouTube, etc.)',
    'audio_url': 'Audio URL',
    'paste_url_hint': 'Paste a URL to embed media on the canvas.',
    // Bottom toolbar
    'invert_colors': 'Invert Colors',
    'screen_capture': 'Screen Capture',
    'auto_alphabet': 'Auto Alphabet',
    'auto_number': 'Auto Number',
    'zoom_in': 'Zoom In',
    'zoom_out': 'Zoom Out',
    'library': 'Library',
    'graph': 'Graph',
    'record': 'Record',
    'stop_recording': 'Stop Recording',
    // Right toolbar
    'text_options': 'Text Options',
    'font_size': 'Size',
    'bold': 'Bold',
    'italic': 'Italic',
    'free_draw': 'Free Draw',
    'curve': 'Curve',
    'rectangle': 'Rectangle',
    'circle': 'Circle',
    'polygon': 'Polygon',
    'triangle': 'Triangle',
    'auto_shape': 'Auto Shape',
    'select': 'Select',
    'rotate': 'Rotate',
    'detail_eraser': 'Detail Eraser',
    // Export/Print
    'export_success': 'Exported successfully.',
    'export_cancelled': 'Export cancelled.',
    'no_lecture_to_export': 'No lecture to export.',
    'lecture_saved': 'Lecture saved.',
    'save_cancelled': 'Save cancelled.',
    // About
    'about_title': 'About ICanNote',
    'version': 'Version',
    // New Lecture Dialog
    'new_lecture_settings': 'New Lecture Settings',
    'page_width': 'Page Width',
    'page_height': 'Page Height',
    'orientation': 'Orientation',
    'landscape': 'Landscape',
    'portrait': 'Portrait',
    'apply': 'Apply',
    'use_defaults': 'Use Defaults',
    // Media
    'video': 'Video',
    'audio': 'Audio',
    'video_link_added': 'Video link added to canvas.',
    'audio_link_added': 'Audio link added to canvas.',
    // Protection
    'save_with_protection_title': 'Save with Protection',
    'password': 'Password',
    'confirm_password': 'Confirm Password',
    'passwords_not_match': 'Passwords do not match.',
    'password_empty': 'Password cannot be empty.',
    'saved_with_protection': 'Lecture saved with protection.',
    'set_password_hint': 'Set a password to protect this lecture file.',
    'enter_password': 'Enter Password',
    'open': 'Open',
    'wrong_password': 'Incorrect password. Could not open the file.',
    // Screen capture
    'no_canvas_to_capture': 'No canvas to capture.',
    'screen_captured': 'Screen captured.',
    'capture_cancelled': 'Capture cancelled.',
    // Page
    'page_info': 'Page',
    // Misc
    'images_loaded': 'image(s) loaded',
    'pdfs_loaded': 'PDF(s) loaded',
    'docs_skipped': 'document(s) skipped',
    'format_not_supported': 'format not yet supported',
    'could_not_open_email': 'Could not open email client.',
    'no_lecture_to_print': 'No lecture to print.',
    'pdf_exported': 'PDF exported.',
    'pdf_export_cancelled': 'PDF export cancelled.',
    'image_exported': 'Image exported.',
    'image_export_cancelled': 'Image export cancelled.',
    // Settings screen
    'reset_all': 'Reset All',
    'settings_reset': 'Settings reset to defaults.',
    'theme_subtitle': 'Choose light or dark mode',
    'theme_light': 'Light',
    'theme_dark': 'Dark',
    'theme_system': 'System',
    'cursor_style_subtitle': 'Canvas cursor appearance',
    'cursor_default': 'Default',
    'cursor_crosshair': 'Crosshair',
    'cursor_dot': 'Dot',
    'show_toolbar_labels': 'Show Toolbar Labels',
    'show_toolbar_labels_subtitle': 'Display text labels on toolbar buttons',
    'language_subtitle': 'App display language',
    'auto_save_subtitle': 'Automatically save lecture periodically',
    'auto_save_interval': 'Auto-Save Interval',
    'auto_save_interval_subtitle_prefix': 'Save every',
    'auto_save_interval_subtitle_suffix': 'seconds',
    'reset_to_defaults': 'Reset to Defaults',
    'app_version': 'ICanNote v1.0.0',
    // Dashboard
    'empty_lectures_hint':
        'Create a new lecture or open an existing file to get started.',
    'pages_suffix': 'pages',
    // Recording overlay
    'rec_prefix': 'REC',
    'play': 'Play',
    'pause': 'Pause',
    'stop': 'Stop',
    'playback_speed': 'Playback Speed',
    // Graph overlay
    'graph_tool': 'Graph Tool',
    'graph_function': 'Function:',
    'graph_grid': 'Grid',
    'graph_axes': 'Axes',
    // Library panel
    'save_preset': 'Save Preset',
    'preset_name': 'Preset Name',
    'no_presets_saved':
        'No presets saved yet.\nSave current page with the + button.',
    'save_current_page_as_preset': 'Save current page as preset',
    'insert_into_canvas': 'Insert into canvas',
    'preset_default_name': 'Preset',
    'elements_suffix': 'elements',
    // Auth screens
    'sign_in_to_account': 'Sign in to your account',
    'email': 'Email',
    'enter_email_first': 'Enter your email first.',
    'password_reset_email_sent': 'Password reset email sent.',
    'please_enter_email': 'Please enter your email',
    'please_enter_valid_email': 'Please enter a valid email',
    'please_enter_password': 'Please enter your password',
    'forgot_password': 'Forgot Password?',
    'sign_in': 'Sign In',
    'no_account_question': "Don't have an account? ",
    'create_account': 'Create Account',
    'continue_as_guest': 'Continue as Guest',
    'display_name': 'Display Name',
    'please_enter_name': 'Please enter your name',
    'please_enter_a_password': 'Please enter a password',
    'password_min_length': 'Password must be at least 6 characters',
    'passwords_do_not_match': 'Passwords do not match',
    'have_account_question': 'Already have an account? ',
    // Payment screen
    'payment': 'Payment',
    'please_log_in_to_subscribe': 'Please log in to subscribe.',
    'log_in': 'Log In',
    'complete_payment': 'Complete Payment',
    'payment_method': 'Payment Method',
    'tosspayments_widget': 'TossPayments Widget',
    'tosspayments_widget_hint':
        'Payment form will be loaded here\nvia TossPayments JavaScript SDK',
    'payment_test_hint':
        'For testing, use the button below to simulate payment:',
    'pay_amount_per_month_prefix': 'Pay',
    'pay_amount_per_month_suffix': '/month',
    'terms_of_service_notice':
        'By subscribing, you agree to our Terms of Service. '
            'Your subscription will automatically renew each month. '
            'You can cancel at any time.',
    'order_summary': 'Order Summary',
    'plan_suffix': 'Plan',
    'total_monthly': 'Total (monthly)',
    'payment_successful': 'Payment Successful!',
    'plan_now_active_prefix': 'Your',
    'plan_now_active_suffix': 'plan is now active.',
    'go_to_dashboard': 'Go to Dashboard',
    'free': 'Free',
    // Subscription screen
    'subscription_plans': 'Subscription Plans',
    'choose_your_plan': 'Choose Your Plan',
    'unlock_full_potential': 'Unlock the full potential of ICanNote',
    'current_plan_prefix': 'Current plan:',
    'most_popular': 'MOST POPULAR',
    'per_month': '/month',
    'unlimited_lectures': 'Unlimited lectures',
    'lectures_count_suffix': 'lectures',
    'unlimited_pages': 'Unlimited pages',
    'pages_per_lecture_suffix': 'pages/lecture',
    'unlimited_collaborators': 'Unlimited collaborators',
    'up_to_collaborators_prefix': 'Up to',
    'up_to_collaborators_suffix': 'collaborators',
    'no_collaboration': 'No collaboration',
    'storage_suffix': 'storage',
    'file_import_feature': 'File import (PDF, PPT, HWP)',
    'lecture_recording': 'Lecture recording',
    'priority_support': 'Priority support',
    'get_started': 'Get Started',
    'subscribe': 'Subscribe',
    'downgrade_to_free_question': 'Downgrade to Free?',
    'downgrade_to_free_content':
        'You will lose access to premium features. '
            'Your subscription will remain active until the end of the current billing period.',
    'downgrade': 'Downgrade',
    'plan_free': 'Free',
    'plan_pro': 'Pro',
    'plan_enterprise': 'Enterprise',
    'plan_free_desc': 'Perfect for getting started',
    'plan_pro_desc': 'For instructors and teams',
    'plan_enterprise_desc': 'For organizations and schools',
    'subscription_details': 'Subscription Details',
    'plan': 'Plan',
    'status': 'Status',
    'next_billing_date': 'Next billing date',
    'cancelled_on': 'Cancelled on',
    'cancel_subscription_question': 'Cancel Subscription?',
    'cancel_subscription_content':
        'Your subscription will remain active until the end '
            'of the current billing period.',
    'keep': 'Keep',
    'cancel_subscription': 'Cancel Subscription',
    // Collaboration
    'failed_to_create_room': 'Failed to create room. Check Firebase config.',
    'room_created': 'Room Created',
    'share_invite_code': 'Share this invite code with participants:',
    'invite_code_copied': 'Invite code copied!',
    'copy_code': 'Copy Code',
    'room_title': 'Room Title',
    'my_lecture_room': 'My Lecture Room',
    'room_not_found_code': 'Room not found. Check the code.',
    'enter_6_char_code': 'Enter the 6-character invite code:',
    'room_not_found_invite_code': 'Room not found. Check the invite code.',
    'joining_room': 'Joining room...',
    'failed_to_join_room': 'Failed to join room.',
    'go_home': 'Go Home',
    'disable_drawing': 'Disable drawing',
    'enable_drawing': 'Enable drawing',
    'code_prefix': 'Code:',
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
    'dashboard': '대시보드',
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
    // Insert menu
    'insert_image': '이미지 삽입',
    'insert_text': '텍스트 삽입',
    'insert_shape': '도형 삽입',
    'insert_line': '선 삽입',
    'insert_sticker': '스티커 삽입',
    // Screen/Background
    'background_color': '배경 색상',
    'background_pattern': '배경 패턴',
    'bg_white': '흰색',
    'bg_light_yellow': '연한 노란색',
    'bg_light_green': '연한 초록색',
    'bg_light_blue': '연한 파란색',
    'bg_light_purple': '연한 보라색',
    'bg_light_coral': '연한 산호색',
    'bg_dark': '어두운색',
    'bg_black': '검정색',
    'pattern_grid': '격자',
    'pattern_ruled': '줄노트',
    'pattern_dots': '도트',
    'pattern_none': '없음 (무지)',
    // Sound/Video
    'insert_sound_video': '소리/동영상 삽입',
    'video_url': '동영상 URL (유튜브 등)',
    'audio_url': '오디오 URL',
    'paste_url_hint': 'URL을 붙여넣어 캔버스에 미디어를 삽입합니다.',
    // Bottom toolbar
    'invert_colors': '색상 반전',
    'screen_capture': '화면 캡처',
    'auto_alphabet': '자동 알파벳',
    'auto_number': '자동 번호',
    'zoom_in': '확대',
    'zoom_out': '축소',
    'library': '라이브러리',
    'graph': '그래프',
    'record': '녹화',
    'stop_recording': '녹화 중지',
    // Right toolbar
    'text_options': '텍스트 옵션',
    'font_size': '크기',
    'bold': '굵게',
    'italic': '기울임',
    'free_draw': '자유 그리기',
    'curve': '곡선',
    'rectangle': '사각형',
    'circle': '원',
    'polygon': '다각형',
    'triangle': '삼각형',
    'auto_shape': '자동 도형',
    'select': '선택',
    'rotate': '회전',
    'detail_eraser': '상세 지우개',
    // Export/Print
    'export_success': '내보내기 완료.',
    'export_cancelled': '내보내기 취소됨.',
    'no_lecture_to_export': '내보낼 강의가 없습니다.',
    'lecture_saved': '강의가 저장되었습니다.',
    'save_cancelled': '저장이 취소되었습니다.',
    // About
    'about_title': 'ICanNote 정보',
    'version': '버전',
    // New Lecture Dialog
    'new_lecture_settings': '새 강의 설정',
    'page_width': '페이지 너비',
    'page_height': '페이지 높이',
    'orientation': '방향',
    'landscape': '가로',
    'portrait': '세로',
    'apply': '적용',
    'use_defaults': '기본값 사용',
    // Media
    'video': '동영상',
    'audio': '오디오',
    'video_link_added': '동영상 링크가 캔버스에 추가되었습니다.',
    'audio_link_added': '오디오 링크가 캔버스에 추가되었습니다.',
    // Protection
    'save_with_protection_title': '보호 저장',
    'password': '비밀번호',
    'confirm_password': '비밀번호 확인',
    'passwords_not_match': '비밀번호가 일치하지 않습니다.',
    'password_empty': '비밀번호를 입력해주세요.',
    'saved_with_protection': '보호된 상태로 저장되었습니다.',
    'set_password_hint': '강의 파일을 보호할 비밀번호를 설정하세요.',
    'enter_password': '비밀번호 입력',
    'open': '열기',
    'wrong_password': '비밀번호가 올바르지 않아 파일을 열 수 없습니다.',
    // Screen capture
    'no_canvas_to_capture': '캡처할 캔버스가 없습니다.',
    'screen_captured': '화면이 캡처되었습니다.',
    'capture_cancelled': '캡처가 취소되었습니다.',
    // Page
    'page_info': '페이지',
    // Misc
    'images_loaded': '개 이미지 로드됨',
    'pdfs_loaded': '개 PDF 로드됨',
    'docs_skipped': '개 문서 건너뜀',
    'format_not_supported': '형식 아직 미지원',
    'could_not_open_email': '이메일 클라이언트를 열 수 없습니다.',
    'no_lecture_to_print': '인쇄할 강의가 없습니다.',
    'pdf_exported': 'PDF가 내보내기되었습니다.',
    'pdf_export_cancelled': 'PDF 내보내기가 취소되었습니다.',
    'image_exported': '이미지가 내보내기되었습니다.',
    'image_export_cancelled': '이미지 내보내기가 취소되었습니다.',
    // Settings screen
    'reset_all': '전체 초기화',
    'settings_reset': '설정이 기본값으로 초기화되었습니다.',
    'theme_subtitle': '밝은 모드 또는 어두운 모드를 선택하세요',
    'theme_light': '밝게',
    'theme_dark': '어둡게',
    'theme_system': '시스템',
    'cursor_style_subtitle': '캔버스 커서 모양',
    'cursor_default': '기본',
    'cursor_crosshair': '십자선',
    'cursor_dot': '점',
    'show_toolbar_labels': '도구 모음 라벨 표시',
    'show_toolbar_labels_subtitle': '도구 모음 버튼에 텍스트 라벨을 표시합니다',
    'language_subtitle': '앱 표시 언어',
    'auto_save_subtitle': '주기적으로 강의를 자동 저장합니다',
    'auto_save_interval': '자동 저장 간격',
    'auto_save_interval_subtitle_prefix': '저장 간격',
    'auto_save_interval_subtitle_suffix': '초',
    'reset_to_defaults': '기본값으로 초기화',
    'app_version': 'ICanNote v1.0.0',
    // Dashboard
    'empty_lectures_hint': '새 강의를 만들거나 기존 파일을 열어 시작하세요.',
    'pages_suffix': '페이지',
    // Recording overlay
    'rec_prefix': 'REC',
    'play': '재생',
    'pause': '일시정지',
    'stop': '정지',
    'playback_speed': '재생 속도',
    // Graph overlay
    'graph_tool': '그래프 도구',
    'graph_function': '함수:',
    'graph_grid': '격자',
    'graph_axes': '좌표축',
    // Library panel
    'save_preset': '프리셋 저장',
    'preset_name': '프리셋 이름',
    'no_presets_saved': '저장된 프리셋이 없습니다.\n+ 버튼으로 현재 페이지를 저장하세요.',
    'save_current_page_as_preset': '현재 페이지를 프리셋으로 저장',
    'insert_into_canvas': '캔버스에 삽입',
    'preset_default_name': '프리셋',
    'elements_suffix': '개 요소',
    // Auth screens
    'sign_in_to_account': '계정에 로그인하세요',
    'email': '이메일',
    'enter_email_first': '이메일을 먼저 입력하세요.',
    'password_reset_email_sent': '비밀번호 재설정 이메일을 보냈습니다.',
    'please_enter_email': '이메일을 입력해주세요',
    'please_enter_valid_email': '올바른 이메일을 입력해주세요',
    'please_enter_password': '비밀번호를 입력해주세요',
    'forgot_password': '비밀번호를 잊으셨나요?',
    'sign_in': '로그인',
    'no_account_question': '계정이 없으신가요? ',
    'create_account': '계정 만들기',
    'continue_as_guest': '게스트로 계속하기',
    'display_name': '표시 이름',
    'please_enter_name': '이름을 입력해주세요',
    'please_enter_a_password': '비밀번호를 입력해주세요',
    'password_min_length': '비밀번호는 6자 이상이어야 합니다',
    'passwords_do_not_match': '비밀번호가 일치하지 않습니다',
    'have_account_question': '이미 계정이 있으신가요? ',
    // Payment screen
    'payment': '결제',
    'please_log_in_to_subscribe': '구독하려면 로그인하세요.',
    'log_in': '로그인',
    'complete_payment': '결제 완료',
    'payment_method': '결제 수단',
    'tosspayments_widget': '토스페이먼츠 위젯',
    'tosspayments_widget_hint': '토스페이먼츠 JavaScript SDK를 통해\n결제 양식이 여기에 로드됩니다',
    'payment_test_hint': '테스트하려면 아래 버튼으로 결제를 시뮬레이션하세요:',
    'pay_amount_per_month_prefix': '',
    'pay_amount_per_month_suffix': '/월 결제',
    'terms_of_service_notice': '구독하시면 서비스 이용약관에 동의하는 것입니다. '
        '구독은 매월 자동으로 갱신됩니다. '
        '언제든지 취소할 수 있습니다.',
    'order_summary': '주문 요약',
    'plan_suffix': '플랜',
    'total_monthly': '합계 (월간)',
    'payment_successful': '결제가 완료되었습니다!',
    'plan_now_active_prefix': '',
    'plan_now_active_suffix': '플랜이 활성화되었습니다.',
    'go_to_dashboard': '대시보드로 이동',
    'free': '무료',
    // Subscription screen
    'subscription_plans': '구독 플랜',
    'choose_your_plan': '플랜을 선택하세요',
    'unlock_full_potential': 'ICanNote의 모든 기능을 활용하세요',
    'current_plan_prefix': '현재 플랜:',
    'most_popular': '가장 인기',
    'per_month': '/월',
    'unlimited_lectures': '무제한 강의',
    'lectures_count_suffix': '개 강의',
    'unlimited_pages': '무제한 페이지',
    'pages_per_lecture_suffix': '페이지/강의',
    'unlimited_collaborators': '무제한 협업자',
    'up_to_collaborators_prefix': '최대',
    'up_to_collaborators_suffix': '명 협업자',
    'no_collaboration': '협업 불가',
    'storage_suffix': '저장 공간',
    'file_import_feature': '파일 가져오기 (PDF, PPT, HWP)',
    'lecture_recording': '강의 녹화',
    'priority_support': '우선 지원',
    'get_started': '시작하기',
    'subscribe': '구독하기',
    'downgrade_to_free_question': '무료 플랜으로 변경하시겠습니까?',
    'downgrade_to_free_content': '프리미엄 기능을 사용할 수 없게 됩니다. '
        '구독은 현재 결제 기간이 끝날 때까지 유지됩니다.',
    'downgrade': '다운그레이드',
    'plan_free': '무료',
    'plan_pro': '프로',
    'plan_enterprise': '엔터프라이즈',
    'plan_free_desc': '시작하기에 적합합니다',
    'plan_pro_desc': '강사 및 팀을 위한 플랜',
    'plan_enterprise_desc': '조직 및 학교를 위한 플랜',
    'subscription_details': '구독 정보',
    'plan': '플랜',
    'status': '상태',
    'next_billing_date': '다음 결제일',
    'cancelled_on': '취소일',
    'cancel_subscription_question': '구독을 취소하시겠습니까?',
    'cancel_subscription_content': '구독은 현재 결제 기간이 끝날 때까지 유지됩니다.',
    'keep': '유지',
    'cancel_subscription': '구독 취소',
    // Collaboration
    'failed_to_create_room': '방 생성에 실패했습니다. Firebase 설정을 확인하세요.',
    'room_created': '방이 생성되었습니다',
    'share_invite_code': '참가자에게 이 초대 코드를 공유하세요:',
    'invite_code_copied': '초대 코드가 복사되었습니다!',
    'copy_code': '코드 복사',
    'room_title': '방 제목',
    'my_lecture_room': '내 강의실',
    'room_not_found_code': '방을 찾을 수 없습니다. 코드를 확인하세요.',
    'enter_6_char_code': '6자리 초대 코드를 입력하세요:',
    'room_not_found_invite_code': '방을 찾을 수 없습니다. 초대 코드를 확인하세요.',
    'joining_room': '방에 참여하는 중...',
    'failed_to_join_room': '방 참여에 실패했습니다.',
    'go_home': '홈으로',
    'disable_drawing': '그리기 비활성화',
    'enable_drawing': '그리기 활성화',
    'code_prefix': '코드:',
  };
}
