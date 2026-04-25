Config = {}

Config.DefaultInteractDistance = 2.0
Config.RequestTimeoutMs = 15000
Config.RequestCooldownMs = 4000

Config.NotifyPrefix = '^3[Nova Interactions]^7 '

Config.SimpleInteractions = {}

local interactionTemplates = {
    handshake_pair = {
        dict = 'mp_ped_interaction',
        initiatorAnim = 'handshake_guy_a',
        targetAnim = 'handshake_guy_b',
        durationMs = 3500
    },
    hug_pair = {
        dict = 'mp_ped_interaction',
        initiatorAnim = 'kisses_guy_a',
        targetAnim = 'kisses_guy_b',
        durationMs = 4000
    },
    wave_pair = {
        dict = 'friends@frj@ig_1',
        initiatorAnim = 'wave_a',
        targetAnim = 'wave_b',
        durationMs = 2500
    },
    salute_single = {
        dict = 'anim@mp_player_intcelebrationmale@salute',
        initiatorAnim = 'salute',
        targetAnim = 'salute',
        durationMs = 2500
    },
    thumbs_up_single = {
        dict = 'anim@mp_player_intincarthumbs_upbodhi@ps@',
        initiatorAnim = 'enter',
        targetAnim = 'enter',
        durationMs = 2200
    },
    clap_single = {
        dict = 'anim@mp_player_intcelebrationmale@slow_clap',
        initiatorAnim = 'slow_clap',
        targetAnim = 'slow_clap',
        durationMs = 3000
    },
    point_single = {
        dict = 'anim@mp_point',
        initiatorAnim = 'task_mp_pointing',
        targetAnim = 'task_mp_pointing',
        durationMs = 2500
    },
    come_here_single = {
        dict = 'gestures@m@standing@casual',
        initiatorAnim = 'gesture_come_here_soft',
        targetAnim = 'gesture_come_here_soft',
        durationMs = 2500
    },
    nod_single = {
        dict = 'gestures@m@standing@casual',
        initiatorAnim = 'gesture_nod_yes_soft',
        targetAnim = 'gesture_nod_yes_soft',
        durationMs = 1800
    },
    no_single = {
        dict = 'gestures@m@standing@casual',
        initiatorAnim = 'gesture_head_no',
        targetAnim = 'gesture_head_no',
        durationMs = 1800
    },
    facepalm_single = {
        dict = 'anim@mp_player_intcelebrationmale@face_palm',
        initiatorAnim = 'face_palm',
        targetAnim = 'face_palm',
        durationMs = 2500
    },
    air_guitar_single = {
        dict = 'anim@mp_player_intcelebrationmale@air_guitar',
        initiatorAnim = 'air_guitar',
        targetAnim = 'air_guitar',
        durationMs = 3000
    },
    dance_single = {
        dict = 'anim@amb@nightclub@mini@dance@dance_solo@male@var_b@',
        initiatorAnim = 'high_center',
        targetAnim = 'high_center',
        durationMs = 4000
    },
    laugh_single = {
        dict = 'anim@mp_player_intcelebrationmale@laugh',
        initiatorAnim = 'laugh',
        targetAnim = 'laugh',
        durationMs = 2500
    },
    cheer_single = {
        dict = 'anim@mp_player_intcelebrationmale@thumbs_up',
        initiatorAnim = 'thumbs_up',
        targetAnim = 'thumbs_up',
        durationMs = 2500
    },
    bro_hug_single = {
        dict = 'anim@mp_player_intcelebrationmale@bro_love',
        initiatorAnim = 'bro_love',
        targetAnim = 'bro_love',
        durationMs = 3000
    }
}

local interactionGroups = {
    {
        baseName = 'handshake',
        baseLabel = 'Handshake',
        template = 'handshake_pair',
        variants = { 'firm', 'quick', 'casual', 'polite', 'friendly', 'respectful', 'business' }
    },
    {
        baseName = 'hug',
        baseLabel = 'Hug',
        template = 'hug_pair',
        variants = { 'warm', 'friendly', 'side', 'reunion', 'comfort', 'supportive', 'grateful' }
    },
    {
        baseName = 'wave',
        baseLabel = 'Wave',
        template = 'wave_pair',
        variants = { 'small', 'big', 'fast', 'calm', 'welcome', 'goodbye', 'signal' }
    },
    {
        baseName = 'salute',
        baseLabel = 'Salute',
        template = 'salute_single',
        variants = { 'formal', 'sharp', 'honor', 'respect', 'parade', 'ceremonial', 'guard' }
    },
    {
        baseName = 'thumbs_up',
        baseLabel = 'Thumbs Up',
        template = 'thumbs_up_single',
        variants = { 'quick', 'confident', 'approval', 'friendly', 'supportive', 'encouraging', 'positive' }
    },
    {
        baseName = 'clap',
        baseLabel = 'Clap',
        template = 'clap_single',
        variants = { 'slow', 'fast', 'loud', 'celebration', 'approval', 'respect', 'crowd' }
    },
    {
        baseName = 'point',
        baseLabel = 'Point',
        template = 'point_single',
        variants = { 'left', 'right', 'ahead', 'warning', 'attention', 'indicate', 'focus' }
    },
    {
        baseName = 'comehere',
        baseLabel = 'Come Here',
        template = 'come_here_single',
        variants = { 'quick', 'urgent', 'friendly', 'calm', 'discreet', 'beckon', 'signal' }
    },
    {
        baseName = 'nod',
        baseLabel = 'Nod',
        template = 'nod_single',
        variants = { 'quick', 'soft', 'approval', 'respect', 'agreement', 'friendly', 'confident' }
    },
    {
        baseName = 'no',
        baseLabel = 'Head Shake',
        template = 'no_single',
        variants = { 'quick', 'firm', 'soft', 'disagree', 'refuse', 'deny', 'warning' }
    },
    {
        baseName = 'facepalm',
        baseLabel = 'Facepalm',
        template = 'facepalm_single',
        variants = { 'frustrated', 'awkward', 'embarrassed', 'disbelief', 'stressed', 'tired', 'annoyed' }
    },
    {
        baseName = 'rock',
        baseLabel = 'Air Guitar',
        template = 'air_guitar_single',
        variants = { 'jam', 'solo', 'hype', 'energy', 'showtime', 'festival', 'stage' }
    },
    {
        baseName = 'dance',
        baseLabel = 'Dance',
        template = 'dance_single',
        variants = { 'club', 'vibe', 'freestyle', 'party', 'groove', 'rhythm', 'show' }
    },
    {
        baseName = 'laugh',
        baseLabel = 'Laugh',
        template = 'laugh_single',
        variants = { 'chuckle', 'giggle', 'hearty', 'awkward', 'mocking', 'nervous', 'joyful' }
    },
    {
        baseName = 'cheer',
        baseLabel = 'Cheer',
        template = 'cheer_single',
        variants = { 'hype', 'victory', 'team', 'crowd', 'sport', 'support', 'celebrate' }
    },
    {
        baseName = 'brohug',
        baseLabel = 'Bro Hug',
        template = 'bro_hug_single',
        variants = { 'quick', 'strong', 'friendly', 'reunion', 'support', 'respect', 'victory' }
    }
}

local function toTitleWords(text)
    return (text:gsub('(%a)([%w_]*)', function(first, rest)
        return string.upper(first) .. string.lower(rest)
    end):gsub('_', ' '))
end

local function addInteraction(name, label, templateKey)
    local template = interactionTemplates[templateKey]

    Config.SimpleInteractions[name] = {
        label = label,
        dict = template.dict,
        initiatorAnim = template.initiatorAnim,
        targetAnim = template.targetAnim,
        durationMs = template.durationMs
    }
end

local function hasInteraction(name)
    return Config.SimpleInteractions[name] ~= nil
end

for _, group in ipairs(interactionGroups) do
    addInteraction(group.baseName, group.baseLabel, group.template)

    for _, variant in ipairs(group.variants) do
        local variantName = ('%s_%s'):format(variant, group.baseName)
        local variantLabel = ('%s %s'):format(toTitleWords(variant), group.baseLabel)
        addInteraction(variantName, variantLabel, group.template)
    end
end

-- Bulk style variants add 200+ extra interactions across all groups.
local universalVariantPrefixes = {
    'alpha',
    'bravo',
    'charlie',
    'delta',
    'echo',
    'foxtrot',
    'gamma',
    'hero',
    'iconic',
    'jolly',
    'kinetic',
    'legend',
    'mellow',
    'nova'
}

for _, group in ipairs(interactionGroups) do
    for _, prefix in ipairs(universalVariantPrefixes) do
        local styleName = ('%s_%s_style'):format(prefix, group.baseName)
        local styleLabel = ('%s %s Style'):format(toTitleWords(prefix), group.baseLabel)

        if not hasInteraction(styleName) then
            addInteraction(styleName, styleLabel, group.template)
        end
    end
end

Config.Hostage = {
    enabled = true,
    interactionDistance = 2.0,
    animDict = 'anim@gangops@hostage@',
    aggressorAnim = 'perp_idle',
    victimAnim = 'victim_idle',
    victimAttach = {
        bone = 0,
        xPos = -0.24,
        yPos = 0.11,
        zPos = 0.0,
        xRot = 0.5,
        yRot = 0.5,
        zRot = 0.0,
        useSoftPinning = false,
        collision = false,
        isPed = false,
        vertexIndex = 2,
        fixedRot = true
    },
    requiredWeapons = {
        'WEAPON_PISTOL',
        'WEAPON_COMBATPISTOL',
        'WEAPON_HEAVYPISTOL',
        'WEAPON_APPISTOL',
        'WEAPON_SNSPISTOL',
        'WEAPON_PISTOL_MK2'
    },
    controls = {
        release = 47,
        execute = 74
    }
}
