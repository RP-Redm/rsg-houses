# WARNING
Unfinished work, if you want you can collaborate to make it much better..

# Dependancies
- rsg-core
- ox_lib
- rsg-menu
- rsg-input
- rsg-npcs
- rsg-bossmenu

# Installation
- ensure that the dependancies are added and started
- add rsg-houses to your resources folder
- add the sql file "houses.sql" to your database

# NPC Setup
- add the following to your rsg-npcs script

```lua
    {    -- estate agent New Hanover
        model = `A_M_O_SDUpperClass_01`,
        coords = vector4(-250.8893, 743.20239, 118.08129, 105.66469),
    },
    {    -- estate agent West Elizabeth
        model = `A_M_O_SDUpperClass_01`,
        coords = vector4(-792.3216, -1203.232, 43.645206, 184.15261),
    },
    {    -- estate agent New Austin
        model = `A_M_O_SDUpperClass_01`,
        coords = vector4(-3658.934, -2620.835, -13.3414, 8.4051847),
    },
    {    -- estate agent Ambarino
        model = `A_M_O_SDUpperClass_01`,
        coords = vector4(-1347.746, 2405.7084, 307.06127, 296.02886),
    },
    {    -- estate agent Lemoyne
        model = `A_M_O_SDUpperClass_01`,
        coords = vector4(2596.5463, -1299.845, 52.817153, 304.04638),
    },
```

# Jobs Setup
- ensure the following Jobs have been setup rsg-core/shared/jobs.lua

```lua
    ['govenor1'] = {
        label = 'Govenor New Hanover',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = {
                name = 'Govenor',
                payment = 100
            },
        },
    },
    ['govenor2'] = {
        label = 'Govenor West Elizabeth',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = {
                name = 'Govenor',
                payment = 100
            },
        },
    },
    ['govenor3'] = {
        label = 'Govenor New Austin',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = {
                name = 'Govenor',
                payment = 100
            },
        },
    },
    ['govenor4'] = {
        label = 'Govenor Ambarino',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = {
                name = 'Govenor',
                payment = 100
            },
        },
    },
    ['govenor5'] = {
        label = 'Govenor Lemoyne',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            ['0'] = {
                name = 'Govenor',
                payment = 100
            },
        },
    },
```

# Starting the resource
- Not finish reconversion all ox_lib
- add the following to your server.cfg file : ensure rsg-houses

# Version oficial thanks
this is a reconverted work from RexShackGaming, by me.
https://github.com/Rexshack-RedM/rsg-houses

# By
https://github.com/Sadicius

# Credits
- RexShack / RexShack#3041 (for the original)
- Sadicius / Sadicius#1150 / https://linktr.ee/sadicius
