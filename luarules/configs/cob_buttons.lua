return {
  --[[
  enterprise = {
    {cob = "NOTHING"},
    {cob = "DOES_NOTHING"},
  },
  core_u4commander = {
    {
     name     = "Sing",
      tooltip  = "A Taunt!",
      cob      = "Sing",  -- only this is required
       endcob   = "SHUDUP",  -- called at the end of duration
      reload   = 10,   -- button is disabled until the reload time has passed
      duration = 1, how long it calls the function
      position = 500,              
    },
  },
  ]]--

  --[[ singing is handeled via dedicated sing/taunt gadget, otherwise this causes double sing buttons
  core_u4commander = {
    {cob = "Sing"},
  },
  core_u3commander = {
    {cob = "Sing"},
  },
  core_u2commander = {
    {cob = "Sing"},
  },
  core_ucommander = {
    {cob = "Sing"},
  },
  core_nincommander = {
    {cob = "Sing"},
  },
  core_u0commander = {
    {cob = "Sing"},
  },
  core_commander = {
    {cob = "Sing"},
  },
  arm_u4commander = {
    {cob = "Sing"},
  },
  arm_u3commander = {
    {cob = "Sing"},
  },
  arm_u2commander = {
    {cob = "Sing"},
  },
  arm_ucommander = {
    {cob = "Sing"},
  },
  arm_u0commander = {
    {cob = "Sing"},
  },
  arm_commander = {
    {cob = "Sing"},
  },
  arm_nincommander = {
    {cob = "Sing"},
  },
  --]]

  talon_berserker = {
    {
	name     = "Overcharge",
	tooltip  = "Overheat to cause 1000 Damage onself",
	cob      = "Overheat",  -- only this is required
     	reload   = 15,
      duration = 1,        
	},
    },
  arm_podger = {
    {
      name     = "Self-Charge",
      tooltip  = "5 second timer 3 seconds to cancel, 4th second will minesweep Destruction after the 5th second!",
      cob      = "SelfD",  -- only this is required
      endcob   = "SelfD",
      reload   = 1,   -- button is disabled until the reload time has passed
      position = 500,
      duration = 1,              
    },
  },
  core_spoiler = {
    {
      name     = "Self-Charge",
      tooltip  = "5 second timer 3 seconds to cancel, 4th second will minesweep Destruction after the 5th second!",
      cob      = "SelfD",  -- only this is required
      endcob   = "SelfD",
      reload   = 1,   -- button is disabled until the reload time has passed
      position = 500,
      duration = 1,                 
    },
  },
  arm_spider = {
    {
      name     = "EMP overload",
      tooltip  = "1 second timer to overload the system, causing damage to the unit and area!",
      cob      = "Overload",  -- only this is required
      --endcob   = "Overload",
      reload   = 0.1,   -- button is disabled until the reload time has passed
      position = 500,
      duration = 1,                 
    },
  },
  arm_annihilator = {
    {
	name     = "OpenState",
	tooltip  = "Select Annihilator's state when idle",
	cob      = "OpenClose",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'0', 'Closed', 'Open'},
	},
  },
  core_doomsday_machine = {
    {
	name     = "OpenState",
	tooltip  = "Select Doomsday Machine's state when idle",
	cob      = "OpenClose",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'0', 'Closed', 'Open'},
	},
  },
  arm_ambusher = {
    {
	name     = "OpenState",
	tooltip  = "Select Ambusher's state when idle",
	cob      = "OpenClose",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'0', 'Closed', 'Open'},
	},
  },
  core_toaster = {
    {
	name     = "OpenState",
	tooltip  = "Select Toaster's state when idle",
	cob      = "OpenClose",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'0', 'Closed', 'Open'},
	},
  },
  core_viper = {
    {
	name     = "OpenState",
	tooltip  = "Select Viper's state when idle",
	cob      = "OpenClose",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'0', 'Closed', 'Open'},
	},
},
  lost_happlic = {
    {
	name     = "OpenState",
	tooltip  = "Select Happlic's state when idle",
	cob      = "OpenClose",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'0', 'Closed', 'Open'},
	},
  },
  lost_obliterator = {
    {
	name     = "OpenState",
	tooltip  = "Select Obliterator's state when idle",
	cob      = "OpenClose",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'0', 'Closed', 'Open'},
	},
  },
  core_nin2commander = {
    {
      name     = "Shield",
      tooltip  = "Invulnerable for 10 seconds!",
      cob      = "ShieldStart",  -- only this is required
      endcob   = "ShieldEnd",  -- called at the end of duration
      reload   = 60,   -- button is disabled until the reload time has passed
	  duration = 10, --how long it calls the function
      position = 500,              
    },
  },
  arm_nin2commander = {
    {
    name     = "Shield",
    tooltip  = "Invulnerable for 10 seconds!",
    cob      = "ShieldStart",  -- only this is required
    endcob   = "ShieldEnd",  -- called at the end of duration
    reload   = 60,   -- button is disabled until the reload time has passed
    duration = 10, --how long it calls the function
    --position = 500,              
    },
  },
  arm_raven_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Raven's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'S.W.A.R.M', 'HE Rockets'},
    },
  },
  core_dominator_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Dominator's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'Guided', 'V Launch'},
    },
  },
  core_crasher_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Crasher's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'S.S.M', 'U.G.M'},
    },
  },
  core_storm_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Storm's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'LR Rocket', 'HD Rocket'},
    },
  },
  arm_jethro_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Jethro's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'S.S.M', 'U.G.M'},
    },
  },
  arm_rocko_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Rocko's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'LR Rocket', 'HD Rocket'},
    },
  },
  arm_samson_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Samson's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'S.S.M', 'U.G.M'},
    },
  },
  core_slasher_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Slasher's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'S.S.M', 'U.G.M'},
    },
  },
  arm_swatter_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Swatter's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'S.S.M', 'U.G.M'},
    },
  },
  core_slinger_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Slinger's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'S.S.M', 'U.G.M'},
    },
  },
  core_diplomat_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Diplomat's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'Guided', 'V Launch'},
    },
  },
  core_missile_frigate_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Rocket Frigate's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'Guided', 'V Launch'},
    },
  },
  arm_merl_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Merl's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'Guided', 'V Launch'},
    },
  },
  arm_ranger_rt = {
    {
	name     = "Rocket type",
	tooltip  = "Select Ranger's rocket type",
	cob      = "RocketType",  -- only this is required
	type = CMDTYPE.ICON_MODE,
	params = {'1', 'Guided', 'V Launch'},
    },

  },
}