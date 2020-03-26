//
//  DataActionAnswer.swift
//  SwolBackEnd
//
//  Created by Pedro Giuliano Farina on 26/03/20.
//  Copyright © 2020 Pedro Giuliano Farina. All rights reserved.
//

import CloudKit

public enum DataActionAnswer {
    case fail(error: CKError, description: String)
    case successful
}
