//
//  StoryModel.swift
//  WhatsAppStoryView
//
//  Created by Raju Kumar on 01/10/23.
//

import Foundation

enum StoryType: String {
    case image
    case video
}

struct Status: Codable {
    let status: [StatusModel]?
}

struct StatusModel: Codable {
    let name: String?
    let profile_image: String?
    let story: [StoryModel]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.profile_image = try container.decodeIfPresent(String.self, forKey: .profile_image)
        self.story = try container.decodeIfPresent([StoryModel].self, forKey: .story)
    }
}

struct StoryModel: Codable {
    let type: String?
    let url: String?
    
     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
    }
}

