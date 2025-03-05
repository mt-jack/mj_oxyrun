Config = {}
 
Config.StartLocation = vector4(-271.3196, 6243.4253, 31.4892, 42.7745) -- Starting ped location for oxy run
Config.StartOxyPayment = 2000 -- How much you pay to start the run

Config.SpawnOxyVehicle = true -- Set to true if you want a vehicle to spawn once the oxyrun has started
Config.VehicleModel = "sultan"
Config.VehicleSpawnLocation = vector4(-258.8525, 6252.2495, 31.4892, 55.7312)

Config.DropOffPeds = { -- the peds that you see when you deliver the oxy
    "a_m_y_busicas_01",
    "a_m_m_hillbilly_02",
    "a_m_m_tramp_01",
    "a_m_y_breakdance_01",
    "g_m_m_chicold_01",
    "g_m_y_lost_02",
    "g_m_y_mexgang_01",
    "g_m_y_salvagoon_01",
    "g_m_y_korlieut_01",
}

Config.CashAmount = {500, 720} -- amount of cash you will in between thoese values
Config.oxychance = 50 -- % chance to get cash

Config.RareItemChance = math.random(1, 3) -- % chance to get the rare item
Config.RareItemAmmount = 1
Config.RareItem = 'laptop_h'

Config.OxyItem = "oxy"
Config.OxyAmount = 1 -- the amount of items returned
Config.MaxRuns = 2  --math.random(5, 10) -- random amount of runs before you complete the run
Config.TBR = math.random(5000, 15000) -- Time between each run in milliseconds
