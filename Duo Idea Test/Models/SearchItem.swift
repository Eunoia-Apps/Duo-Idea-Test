//
//  SearchItem.swift
//  Duo Idea Test
//
//  Created by Bigba on 2/18/25.
//

import Foundation

struct SearchItem: Codable, Identifiable {
    let id = UUID()
    
    let title: String
    let link: String
    var postDate: Date
    var aiScore: Double = 0.0
    
    var isLiked: Bool = false
    var isDisliked: Bool = false
    var category: String = ""
    
    var thumbnail: URL?
    var commentCount: Int = 0
    var upvoteCount: Int = 0
    var text: String = ""
}


extension SearchItem {
    
    mutating func likePost() {
        self.isLiked = true
        
        if let currentCount = AlgorithmCore.shared.likedCategories[self.category] {
            AlgorithmCore.shared.likedCategories[self.category] = currentCount + 1
        } else {
            AlgorithmCore.shared.likedCategories[self.category] = 1  // If the category doesn't exist, initialize it with 1
        }
        
        AlgorithmCore.shared.likedPosts.append(self)
    }
    
    mutating func unlikePost() {
        self.isLiked = false
        
        if let currentCount = AlgorithmCore.shared.likedCategories[self.category] {
            AlgorithmCore.shared.likedCategories[self.category] = currentCount - 1
        }
        
        AlgorithmCore.shared.likedPosts.removeAll { post in
            (post.link == self.link) && (post.title == self.title)
        }
    }
    
    
    mutating func dislikePost() {
        self.isLiked = false
        
        if let currentCount = AlgorithmCore.shared.likedCategories[self.category] {
            AlgorithmCore.shared.likedCategories[self.category] = currentCount - 1
        } else {
            AlgorithmCore.shared.likedCategories[self.category] = -1  // If the category doesn't exist, initialize it with -1
        }
        
        AlgorithmCore.shared.dislikedPosts.append(self)
    }
    
    
    // Calculates the AI score based on recency, liked status, category, and title length.
    mutating func calculateAIScore() {
        //        print(AlgorithmCore.shared.likedPosts)
        var score = 0.0
        
        // Factor 1: Recency - More recent posts get a higher score.
        // Calculate days elapsed since the post date.
        let timeInterval = Date().timeIntervalSince(postDate)
        let daysSincePost = timeInterval / (60 * 60 * 24)
        
        // Assume a maximum of 50 points for posts made today, decreasing by 1 point per day.
        let recencyScore = max(0, 50 - daysSincePost)
        score += recencyScore
        
        let voteScore = (self.upvoteCount * 3/2)
        score += Double(voteScore)
        
        let commentScore = (self.commentCount * 3/2)
        score += Double(commentScore)
        
        // Factor 3: How many times the post's category has been liked by user
        
        if let currentCount = AlgorithmCore.shared.likedCategories[self.category] {
            score += Double((currentCount * 3/2))
        }
        
        
        // Factor 4: Title Length - A bonus for shorter titles
        if title.count < 20 {
            score += 5
        }
        
        // Update the aiScore property.
        self.aiScore = score
    }
}


