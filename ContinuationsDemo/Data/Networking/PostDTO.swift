//
//  PostDTO.swift
//  ContinuationsDemo
//
//  Created by Abraham Gonzalez Puga on 19/02/26.
//

struct PostDTO: Decodable {
    let id: Int
    let title: String
    let body: String
}

extension PostDTO {
    func toDomain() -> Post {
        Post(
            id: self.id,
            title: self.title,
            body: self.body
        )
    }
}
