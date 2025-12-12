package spilehx.p2pserver;

import spilehx.p2pserver.server.usersocketupdatemanager.UserSocketUpdateManager;
import spilehx.p2pserver.server.restservicemanager.RestServerManager;
import spilehx.core.threadservices.ThreadedServiceErrorManager;
import spilehx.core.threadservices.ThreadedServiceManager;
import spilehx.core.logger.GlobalLoggingSettings;

class P2PServerController {
	public function new() {}

	public function init() {
		GlobalLoggingSettings.settings.verbose = true;
		ThreadedServiceManager.instance.onTooManyThreadErrors = ThreadedServiceErrorManager.onTooManyThreadErrors;
		initManagers();
	}

	private function initManagers() {
		ThreadedServiceManager.instance.addService(RestServerManager, [], "RestServerManager", onCriticalServiceExit);
		ThreadedServiceManager.instance.addService(UserSocketUpdateManager, [], "UserSocketUpdateManager", onCriticalServiceExit);
	}

	private function onCriticalServiceExit() {
		LOG_ERROR("Critical Service Exit");
	}
}
