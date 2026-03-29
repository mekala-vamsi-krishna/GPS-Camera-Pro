//
//  HomePresenter.swift
//  GPS-Camera-Pro
//
//  Created by User on 29/03/26.
//

import Foundation
import Combine
class HomePresenter : ObservableObject {
    @Published var isLoading : Bool = false
    @Published  var isError : Bool = false
    @Published var errorMessege : String = ""
    
    init () {
        print("Home Presenter initlized")
    }
    
    deinit {
        print("Home Presenter deinitzed")
    }
    
    
}
