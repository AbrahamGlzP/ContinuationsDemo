//
//  PostsView.swift
//  ContinuationsDemo
//
//  Created by Abraham Gonzalez Puga on 19/02/26.
//

import SwiftUI

@MainActor
class PostsViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let service: NetworkService
    
    init(service: NetworkService) {
        self.service = service
    }
    
    func loadPosts() async {
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            // We can now use the method using async/await but internally URLSession uses completion handlers
            posts = try await service.fetchPosts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct PostsView: View {
    
    @StateObject private var viewModel: PostsViewModel = PostsViewModel(service: NetworkService())
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading posts")
                } else {
                    List(viewModel.posts, id: \.id) { post in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(post.title)
                                .font(.headline)
                            Text(post.body)
                                .font(.caption)
                                .foregroundStyle(ForegroundStyle().secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Continuations Demo")
            .task {
                await viewModel.loadPosts()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}
