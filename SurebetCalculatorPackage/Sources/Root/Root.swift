import AppMetricaCore
import SwiftUI

public enum Root {
    // MARK: - Public Methods

    public static func view() -> some View {
        RootView()
    }
}

// MARK: - AppMetrica
public typealias AppMetrica = AppMetricaCore.AppMetrica
public typealias AppMetricaConfiguration = AppMetricaCore.AppMetricaConfiguration
