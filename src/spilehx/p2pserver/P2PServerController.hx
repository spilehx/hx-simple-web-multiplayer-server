package spilehx.p2pserver;

import spilehx.p2pserver.server.settingsmanager.SettingsManager;
import spilehx.p2pserver.server.socketupdatemanager.SocketUpdateManager;
import spilehx.p2pserver.server.restservicemanager.RestServerManager;
import spilehx.core.threadservices.ThreadedServiceErrorManager;
import spilehx.core.threadservices.ThreadedServiceManager;
import spilehx.core.logger.GlobalLoggingSettings;

class P2PServerController {
	public function new() {}

	public function init() {
		GlobalLoggingSettings.settings.verbose = (SettingsManager.instance.settings.verboseLogging == "true");
		ThreadedServiceManager.instance.onTooManyThreadErrors = ThreadedServiceErrorManager.onTooManyThreadErrors;
		initManagers();
	}

	private function initManagers() {
		ThreadedServiceManager.instance.addService(RestServerManager, [], "RestServerManager", onCriticalServiceExit);
		ThreadedServiceManager.instance.addService(SocketUpdateManager, [], "SocketUpdateManager", onCriticalServiceExit);
	}

	private function onCriticalServiceExit() {
		LOG_ERROR("Critical Service Exit");
	}
}
