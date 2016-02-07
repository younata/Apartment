import ApartKit

struct TestUtils {

    // Mark: Services

    static var allServices: [Service] {
        return [
            self.lightService,
            self.mqttService,
            self.switchService,
            self.sceneService,
            self.homeAssistantService,
            self.mediaPlayerService,
            self.deviceTrackerService
        ]
    }

    static let mediaPlayerService = Service(domain: "media_player", methods: [
        Service.Method(id: "start_epic_sax", description: "", fields: [:]),
        Service.Method(id: "turn_off", description: "", fields: [:]),
        Service.Method(id: "volume_set", description: "", fields: [:]),
        Service.Method(id: "start_fireplace", description: "", fields: [:]),
        Service.Method(id: "play_media", description: "", fields: [:]),
        Service.Method(id: "media_previous_track", description: "", fields: [:]),
        Service.Method(id: "media_play", description: "", fields: [:]),
        Service.Method(id: "turn_on", description: "", fields: [:]),
        Service.Method(id: "media_pause", description: "", fields: [:]),
        Service.Method(id: "volume_mute", description: "", fields: [:]),
        Service.Method(id: "media_next_track", description: "", fields: [:]),
        Service.Method(id: "media_play_pause", description: "", fields: [:]),
        Service.Method(id: "volume_up", description: "", fields: [:]),
        Service.Method(id: "media_seek", description: "", fields: [:]),
        Service.Method(id: "play_youtube_video", description: "", fields: [:]),
        Service.Method(id: "volume_down", description: "", fields: [:]),
    ])

    static let deviceTrackerService = Service(domain: "device_tracker", methods: [
        Service.Method(id: "see", description: "", fields: [:]),
    ])

    static let homeAssistantService = Service(domain: "homeassistant", methods: [
        Service.Method(id: "turn_off", description: "", fields: [:]),
        Service.Method(id: "stop", description: "", fields: [:]),
        Service.Method(id: "turn_on", description: "", fields: [:]),
    ])

    static let sceneService = Service(domain: "scene", methods: [
        Service.Method(id: "turn_on", description: "", fields: [:]),
    ])

    static let switchService = Service(domain: "switch", methods: [
        Service.Method(id: "turn_off", description: "", fields: [:]),
        Service.Method(id: "turn_on", description: "", fields: [:]),
    ])

    static let mqttService = Service(domain: "mqtt", methods: [
        Service.Method(id: "publish", description: "", fields: [:]),
    ])

    static let lightService = Service(domain: "light", methods: [
        Service.Method(id: "turn_off", description: "Turn a light off", fields: [
            "entity_id": [
                "description": "Name(s) of entities to turn off",
                "example": "light.kitchen"
            ],
            "transition": [
                "description": "Duration in seconds it takes to get to the next state",
                "example": 60
            ]
        ]),
        Service.Method(id: "turn_on", description: "Turn a light on", fields: [
            "brightness": [
                "description": "Number between 0..255 indicating brightness",
                "example": 120
            ],
            "color_temp": [
                "description": "Color temperature for the light in mireds (154-500)",
                "example": "250"
            ],
            "effect": [
                "description": "Light effect",
                "values": [
                    "colorloop"
                ]
            ],
            "entity_id": [
                "description": "Name(s) of entities to turn on",
                "example": "light.kitchen"
            ],
            "flash": [
                "description": "If the light should flash",
                "values": [
                    "short",
                    "long"
                ]
            ],
            "profile": [
                "description": "Name of a light profile to use",
                "example": "relax"
            ],
            "rgb_color": [
                "description": "Color for the light in RGB-format",
                "example": "[255, 100, 100]"
            ],
            "transition": [
                "description": "Duration in seconds it takes to get to next state",
                "example": 60
            ],
            "xy_color": [
                "description": "Color for the light in XY-format",
                "example": "[0.52, 0.43]"
            ]
        ])
    ])
}