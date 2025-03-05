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

Config.DropOffLocation = {
    -- vector4(67.46, 3759.93, 39.74, 192.14),
    -- vector4(1693.98, 3460.74, 37.01, 26.68),
    -- vector4(1656.05, 4862.07, 41.99, 276.37),
    -- vector4(710.21, 4183.31, 40.71, 188.52),
    -- vector4(2419.16, 3737.78, 42.25, 16.06),
    -- vector4(2393.34, 3320.56, 48.03, 313.71),


    vector4(1532.7223, 6329.7910, 24.2959, 70.8775),
    vector4(3322.4685, 5142.9712, 18.3721, 41.6794),
    vector4(2490.4810, 3425.2856, 50.1879, 101.1638),
    vector4(1745.4135, 3017.6042, 63.8577, 354.4006),
    vector4(972.1368, 3579.0149, 32.3461, 342.9962),
    vector4(-13.0655, 3197.7207, 40.3945, 54.5086),
}

-- Opening hours
Config.EnableOpeningHours = true -- Enable opening hours? If disabled you can always open the pawnshop.
Config.OpenHour = 9 -- From what hour should the pawnshop be open?
Config.CloseHour = 21 -- From what hour should the pawnshop be closed?
