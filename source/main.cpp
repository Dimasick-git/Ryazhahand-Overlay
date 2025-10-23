#include "globalvars.hpp"
using namespace ult;

int main(int argc, char* argv[]) {
    printf("%s\n", RYAZHAHAND_HAS_STARTED.c_str());

    auto data = getKeyValuePairsFromSection(RYAZHAHAND_CONFIG_INI_PATH, RYAZHAHAND_PROJECT_NAME);

    bool hideClock   = (data["hide_clock"] == "true");
    bool hideBattery = (data["hide_battery"] == "true");

    auto syncWidgetStates = [&]() {
        auto updated = getKeyValuePairsFromSection(RYAZHAHAND_CONFIG_INI_PATH, RYAZHAHAND_PROJECT_NAME);
        hideClock   = (updated["hide_clock"] == "true");
        hideBattery = (updated["hide_battery"] == "true");
        // Добавь сюда остальные параметры по необходимости
    };

    auto saveWidgetState = [&](const std::string& key, bool value) {
        setIniFileValue(RYAZHAHAND_CONFIG_INI_PATH, RYAZHAHAND_PROJECT_NAME, key, value ? "true" : "false");
        syncWidgetStates();
    };

    // Например: saveWidgetState("hide_clock", true);

    // Вся логика overlay/меню — только на глобалах RYAZHAHAND!

    return 0;
}
