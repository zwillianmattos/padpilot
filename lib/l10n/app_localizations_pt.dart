// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String get howToConnect => 'Como conectar';

  @override
  String get profiles => 'Perfis';

  @override
  String get settings => 'Configurações';

  @override
  String get permissionsPending => 'Permissões pendentes';

  @override
  String get back => 'Voltar';

  @override
  String get gotIt => 'Entendi';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get name => 'Nome';

  @override
  String get connectTitle => 'Conectar um controle';

  @override
  String get tipUsbTitle => 'USB';

  @override
  String get tipUsb => 'Conecte o cabo. O controle aparece aqui em alguns segundos.';

  @override
  String get tipBluetoothTitle => 'Bluetooth';

  @override
  String get tipBluetooth => 'Coloque o controle em modo de pareamento e conecte em Ajustes do Sistema › Bluetooth.';

  @override
  String get tipXbox360Title => 'Xbox 360 sem fio';

  @override
  String get tipXbox360 => 'Não usa Bluetooth: exige o receptor da Microsoft.';

  @override
  String get tipPs3Title => 'PS3 via USB';

  @override
  String get tipPs3 => 'Talvez seja preciso pressionar o botão PS uma vez.';

  @override
  String get tipHidTitle => 'Controles genéricos';

  @override
  String get tipHid => 'Exigem a permissão de Monitoramento de Entrada para serem detectados.';

  @override
  String get connected => 'Conectado';

  @override
  String get genericHid => 'HID genérico';

  @override
  String get controllerFallback => 'Controle';

  @override
  String get noController => 'Nenhum controle conectado';

  @override
  String get noControllerHint => 'Conecte por USB ou Bluetooth. Ele aparecerá aqui automaticamente.';

  @override
  String get editAnyway => 'Editar perfil mesmo assim';

  @override
  String get switchActiveProfile => 'Trocar perfil em uso';

  @override
  String get profileInUse => 'Perfil em uso:';

  @override
  String get mappingEnable => 'Ligar mapeamento';

  @override
  String get mappingDisable => 'Desligar mapeamento';

  @override
  String get mappingActive => 'Mapeamento ativo';

  @override
  String get mappingPaused => 'Mapeamento pausado';

  @override
  String get profileEditor => 'Editor de perfil';

  @override
  String get detectButton => 'Detectar botão';

  @override
  String get waitingController => 'Aguardando controle…';

  @override
  String get switchProfile => 'Trocar perfil';

  @override
  String get profileLabel => 'Perfil:';

  @override
  String get manageProfiles => 'Gerenciar perfis…';

  @override
  String get inUse => 'Em uso';

  @override
  String get useThisProfile => 'Usar este perfil';

  @override
  String get statusCapturing => 'Pressione um botão, gatilho ou mova um analógico no controle';

  @override
  String get statusOffline => 'Nenhum controle conectado — você ainda pode editar o perfil';

  @override
  String get statusConnected => 'Clique em um ponto do controle para atribuir uma ação';

  @override
  String get statusDisconnected => 'Controle desconectado';

  @override
  String get assignments => 'Atribuições';

  @override
  String actionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ações',
      one: '1 ação',
      zero: 'Nenhuma ação',
    );
    return '$_temp0';
  }

  @override
  String actionsInProfile(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ações neste perfil',
      one: '1 ação neste perfil',
      zero: 'Nenhuma ação neste perfil',
    );
    return '$_temp0';
  }

  @override
  String get allControls => 'Todos os controles';

  @override
  String get bothFireWarning =>
      'O analógico inteiro e as direções estão atribuídos ao mesmo tempo; ambos vão disparar.';

  @override
  String get notAssigned => 'Não atribuído';

  @override
  String get leftStick => 'Analógico esquerdo';

  @override
  String get rightStick => 'Analógico direito';

  @override
  String get dpad => 'Direcional';

  @override
  String get triangle => 'Triângulo';

  @override
  String get square => 'Quadrado';

  @override
  String get circle => 'Círculo';

  @override
  String get cross => 'Xis';

  @override
  String get wholeStick => 'Analógico inteiro';

  @override
  String get dirUp => 'Para cima';

  @override
  String get dirDown => 'Para baixo';

  @override
  String get dirLeft => 'Para a esquerda';

  @override
  String get dirRight => 'Para a direita';

  @override
  String get press => 'Pressionar';

  @override
  String pressNamed(String name) {
    return 'Pressionar ($name)';
  }

  @override
  String get kindNone => 'Nenhuma';

  @override
  String get kindKey => 'Tecla';

  @override
  String get kindClick => 'Clique';

  @override
  String get kindMove => 'Mover mouse';

  @override
  String get kindScroll => 'Rolar';

  @override
  String get mouseLeft => 'Esquerdo';

  @override
  String get mouseMiddle => 'Meio';

  @override
  String get mouseRight => 'Direito';

  @override
  String get clickHint => 'Segure para arrastar. Dois toques rápidos fazem clique duplo.';

  @override
  String get responseCurve => 'Curva de resposta';

  @override
  String get curveLinear => 'Linear';

  @override
  String get curveQuadratic => 'Quadrática';

  @override
  String get curveExponential => 'Exponencial';

  @override
  String get deadzone => 'Zona morta';

  @override
  String get speed => 'Velocidade';

  @override
  String get speedAll => 'Todas';

  @override
  String get sameSpeedAllDirections => 'Mesma em todas as direções';

  @override
  String get vertical => 'Vertical';

  @override
  String get horizontal => 'Horizontal';

  @override
  String get invertDirection => 'Inverter direção';

  @override
  String get linesPerStep => 'Linhas por passo';

  @override
  String get triggerFrom => 'Acionar a partir de';

  @override
  String get actionMoveMouse => 'Mover mouse';

  @override
  String get actionClickLeft => 'Clique esquerdo';

  @override
  String get actionClickRight => 'Clique direito';

  @override
  String get actionClickMiddle => 'Clique do meio';

  @override
  String get actionScrollUp => 'Rolar para cima';

  @override
  String get actionScrollDown => 'Rolar para baixo';

  @override
  String get actionScrollLeft => 'Rolar para a esquerda';

  @override
  String get actionScrollRight => 'Rolar para a direita';

  @override
  String keyFallback(int code) {
    return 'Tecla $code';
  }

  @override
  String get keySpace => 'Espaço';

  @override
  String keyRight(String name) {
    return '$name direito';
  }

  @override
  String get pressAKey => 'Pressione uma tecla…';

  @override
  String get clickToRecord => 'Clique para gravar';

  @override
  String get record => 'Gravar';

  @override
  String get newProfile => 'Novo perfil';

  @override
  String get import => 'Importar';

  @override
  String get restoreSamples => 'Restaurar perfis de exemplo';

  @override
  String get defaultProfileName => 'Meu perfil';

  @override
  String imported(String name) {
    return '“$name” importado';
  }

  @override
  String get invalidProfileFile => 'Este arquivo não é um perfil válido.';

  @override
  String get samplesRestored => 'Perfis de exemplo restaurados';

  @override
  String errorLoadingProfiles(String error) {
    return 'Erro ao carregar perfis: $error';
  }

  @override
  String get profileExported => 'Perfil exportado';

  @override
  String deleteProfileTitle(String name) {
    return 'Excluir “$name”?';
  }

  @override
  String get cannotBeUndone => 'Esta ação não pode ser desfeita.';

  @override
  String get renameProfile => 'Renomear perfil';

  @override
  String get moreActions => 'Mais ações';

  @override
  String get rename => 'Renomear';

  @override
  String get duplicate => 'Duplicar';

  @override
  String get exportMenu => 'Exportar…';

  @override
  String copyName(String name) {
    return '$name (cópia)';
  }

  @override
  String get profileFileType => 'Perfil PadPilot';

  @override
  String get welcome => 'Bem-vindo ao PadPilot';

  @override
  String get permissions => 'Permissões';

  @override
  String get tagline => 'Use seu controle para comandar qualquer app ou jogo no Mac.';

  @override
  String get accessibility => 'Acessibilidade';

  @override
  String get accessibilityDesc => 'Permite que o PadPilot simule teclado, mouse, cliques e rolagem.';

  @override
  String get inputMonitoring => 'Monitoramento de Entrada';

  @override
  String get inputMonitoringDesc =>
      'Necessária apenas para controles HID genéricos. Controles Xbox, PlayStation e Switch funcionam sem ela.';

  @override
  String get permissionsAutoUpdate =>
      'Após ativar em Ajustes do Sistema o status atualiza sozinho. Se não atualizar, feche e abra o PadPilot novamente.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get continueAnyway => 'Continuar mesmo assim';

  @override
  String get required => 'Obrigatória';

  @override
  String get optional => 'Opcional';

  @override
  String get allowed => 'Permitido';

  @override
  String get openSystemSettings => 'Abrir Ajustes do Sistema';

  @override
  String get general => 'Geral';

  @override
  String get launchAtLogin => 'Abrir ao iniciar sessão';

  @override
  String get launchAtLoginDesc => 'O PadPilot inicia na barra de menus quando você entra no Mac.';

  @override
  String couldNotChange(String error) {
    return 'Não foi possível alterar: $error';
  }

  @override
  String get globalShortcut => 'Atalho global';

  @override
  String get globalShortcutDesc => 'Liga e desliga o mapeamento de qualquer lugar.';

  @override
  String get shortcutNeedsModifier => 'Use pelo menos um modificador (⌘, ⌥, ⌃ ou ⇧).';

  @override
  String get shortcutInUse => 'Esse atalho já está em uso por outro app.';

  @override
  String get removeShortcut => 'Remover atalho';

  @override
  String get permissionDenied => 'Não permitido';

  @override
  String get permissionUnknown => 'Não solicitado';

  @override
  String get managePermissions => 'Gerenciar permissões';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get trayMappingActive => 'Mapeamento ativo';

  @override
  String trayProfile(String name) {
    return 'Perfil: $name';
  }

  @override
  String get trayOpen => 'Abrir PadPilot';

  @override
  String get trayQuit => 'Sair do PadPilot';

  @override
  String get sampleMediaPlayer => 'Media Player';

  @override
  String get sampleNavigation => 'Navegação';

  @override
  String get samplePhotoEditing => 'Edição de fotos';

  @override
  String get diagnostics => 'Diagnóstico do controle';

  @override
  String get diagnosticsShort => 'Diagnóstico';

  @override
  String get resetStats => 'Zerar medições';

  @override
  String eventsPerSecond(int rate) {
    return '$rate eventos/s';
  }

  @override
  String get rangeX => 'Faixa X';

  @override
  String get rangeY => 'Faixa Y';

  @override
  String get resolution => 'Resolução';

  @override
  String resolutionValue(String bits, int levels) {
    return '≈$bits bits ($levels passos)';
  }

  @override
  String get measuring => 'Mova o analógico para medir';

  @override
  String get outerRadius => 'Alcance médio na borda';

  @override
  String get circularityError => 'Erro de circularidade';

  @override
  String get center => 'Deslocamento do centro';

  @override
  String get noise => 'Ruído em repouso (σ)';

  @override
  String get suggestedDeadzone => 'Zona morta sugerida';

  @override
  String get calibrateCenter => 'Calibrar centro';

  @override
  String calibrating(int seconds) {
    return 'Não mexa… ${seconds}s';
  }

  @override
  String calibrationSamples(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count amostras em repouso',
      one: '1 amostra em repouso',
      zero: 'Sem movimento em repouso (estável)',
    );
    return '$_temp0';
  }

  @override
  String get applyDeadzone => 'Aplicar no perfil';

  @override
  String deadzoneApplied(int percent, String profile) {
    return 'Zona morta de $percent% aplicada em “$profile”';
  }

  @override
  String get noMouseMapping =>
      'No perfil em uso este analógico não move o mouse, então não há zona morta para aplicar.';

  @override
  String get triggers => 'Gatilhos';

  @override
  String get rawHid => 'HID bruto';

  @override
  String get rawHidDesc =>
      'Contagens do sensor direto do relatório HID, antes da filtragem e normalização do GameController do macOS. Exige Monitoramento de Entrada.';

  @override
  String get rawHidEmpty =>
      'Ainda sem dados HID brutos. Mova um analógico; se nada aparecer, conceda Monitoramento de Entrada.';

  @override
  String get gcNote =>
      'Os valores acima vêm do GameController, que o macOS já normaliza. Use HID bruto para inspecionar o sinal real do sensor.';

  @override
  String get waitingInput => 'Mova um analógico ou gatilho para começar';

  @override
  String get games => 'Jogos';

  @override
  String get gameHub => 'Central de jogos';

  @override
  String get rowContinue => 'Continue jogando';

  @override
  String get rowPinned => 'Fixados';

  @override
  String get rowNeedsPadPilot => 'Precisam do PadPilot';

  @override
  String get rowReady => 'Prontos para jogar';

  @override
  String get rowUnmapped => 'Ainda sem perfil';

  @override
  String get rowNative => 'Suporte nativo a controle';

  @override
  String get rowOwned => 'Na biblioteca, não instalados';

  @override
  String get rowWindowsOnly => 'Somente Windows';

  @override
  String get rowFeatured => 'Destaques na Steam';

  @override
  String get rowSearch => 'Resultados da busca';

  @override
  String get badgeFull => 'Suporte total a controle';

  @override
  String get badgePartial => 'Suporte parcial a controle';

  @override
  String get badgeNone => 'Sem suporte a controle';

  @override
  String get badgeWindowsOnly => 'Somente Windows';

  @override
  String get badgeInstalled => 'Instalado';

  @override
  String discount(int percent) {
    return '-$percent%';
  }

  @override
  String get play => 'Jogar';

  @override
  String get details => 'Detalhes';

  @override
  String get openStore => 'Página da loja';

  @override
  String get padpilotForGame => 'PadPilot neste jogo';

  @override
  String get profileForGame => 'Perfil';

  @override
  String get useProfileInUse => 'Usar o perfil em uso';

  @override
  String get autoSwitch => 'Trocar automaticamente';

  @override
  String get autoSwitchDesc => 'Usa este perfil enquanto o jogo estiver em primeiro plano e depois volta ao anterior.';

  @override
  String get padpilotOffForGame => 'Desligar o PadPilot neste jogo';

  @override
  String get padpilotOffDesc =>
      'Recomendado quando o jogo já suporta controle nativamente, para evitar comandos duplicados.';

  @override
  String get hideGame => 'Ocultar da central';

  @override
  String get pinGame => 'Fixar no topo';

  @override
  String get createProfileForGame => 'Novo perfil para este jogo';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String suggested(String name) {
    return 'Sugerido: $name';
  }

  @override
  String get useSuggestion => 'Usar';

  @override
  String get playtime => 'Tempo de jogo';

  @override
  String playtimeHours(String hours) {
    return '$hours h';
  }

  @override
  String get lastPlayed => 'Última sessão';

  @override
  String get installSize => 'Tamanho em disco';

  @override
  String get releaseDate => 'Lançamento';

  @override
  String get genres => 'Gêneros';

  @override
  String get developer => 'Desenvolvedora';

  @override
  String get platforms => 'Plataformas';

  @override
  String nowPlaying(String game, String profile) {
    return 'Jogando $game · perfil $profile';
  }

  @override
  String nowPlayingPaused(String game) {
    return 'Jogando $game · PadPilot desligado';
  }

  @override
  String gamesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jogos',
      one: '1 jogo',
      zero: 'Nenhum jogo',
    );
    return '$_temp0';
  }

  @override
  String get steamNotFound => 'A Steam não está instalada neste Mac';

  @override
  String get steamNotFoundDesc =>
      'Instale a Steam para ver seus jogos aqui, ou vincule sua conta Steam para ver os jogos que você possui.';

  @override
  String get linkSteam => 'Vincular conta Steam';

  @override
  String get steamAccount => 'Conta Steam';

  @override
  String linkedAs(String name) {
    return 'Vinculada como $name';
  }

  @override
  String get unlink => 'Desvincular';

  @override
  String get apiKey => 'Chave da Web API';

  @override
  String get steamId => 'SteamID64';

  @override
  String get getApiKey => 'Obter uma chave';

  @override
  String get linkSteamDesc =>
      'Opcional: adiciona jogos que você possui mas não instalou, e o tempo de jogo. A chave fica no Keychain do macOS e só é enviada à Steam.';

  @override
  String linkFailed(String error) {
    return 'Não foi possível vincular: $error';
  }

  @override
  String get invalidKey => 'A Steam recusou essa chave ou SteamID.';

  @override
  String get privateProfileHint =>
      'A Steam não retornou jogos. Verifique se os detalhes de jogos do seu perfil estão públicos.';

  @override
  String get link => 'Vincular';

  @override
  String get searchGames => 'Buscar jogos';

  @override
  String get offlineError => 'Não foi possível acessar a Steam. Mostrando o que está em cache.';

  @override
  String get noDescription => 'Sem descrição disponível.';

  @override
  String get loading => 'Carregando…';

  @override
  String get diagStep1 => 'Gire cada analógico devagar encostado na borda, algumas voltas completas.';

  @override
  String get diagStep2 => 'Solte, toque em “Calibrar centro” e não mexa por 2 s.';

  @override
  String get diagStep3 => 'Aplique a zona morta sugerida no perfil em uso.';

  @override
  String get groupSignal => 'Sinal';

  @override
  String get groupCircularity => 'Circularidade';

  @override
  String get groupCenter => 'Centro em repouso';

  @override
  String get positionX => 'Posição X';

  @override
  String get positionY => 'Posição Y';

  @override
  String get coverageShort => 'Borda percorrida';

  @override
  String get rotateMore => 'Gire mais para medir';

  @override
  String get legendEnvelope => 'Contorno da borda';

  @override
  String get legendDeadzone => 'Zona morta';

  @override
  String get legendCenter => 'Centro medido';

  @override
  String get legendTrail => 'Movimento recente';

  @override
  String get verdictGood => 'Bom';

  @override
  String get verdictWarn => 'Atenção';

  @override
  String get verdictBad => 'Ruim';

  @override
  String get notMeasured => 'Não medido';

  @override
  String get triggerLeft => 'Gatilho esquerdo';

  @override
  String get triggerRight => 'Gatilho direito';

  @override
  String get axis => 'Eixo';

  @override
  String get bits => 'Bits';

  @override
  String get toggleShortcutTitle => 'Ligar/desligar mapeamento';

  @override
  String get open => 'Abrir';

  @override
  String get padpilotOffShort => 'PadPilot desligado';

  @override
  String get notListedHint =>
      'O PadPilot não aparece na lista? Clique em “+” nos Ajustes do Sistema e escolha PadPilot.app.';

  @override
  String get revealApp => 'Mostrar app no Finder';

  @override
  String get restartApp => 'Reiniciar PadPilot';

  @override
  String get restartRequiredDesc => 'Monitoramento de Entrada permitido. Reinicie o PadPilot para valer.';

  @override
  String get windowsPreview =>
      'Prévia no Windows: perfis e central de jogos funcionam, mas o mapeamento do controle ainda não está disponível no Windows.';
}
