import Foundation
import UIKit
import FirebaseFirestore


class GenreViewController: UIViewController{
    
    
    @IBOutlet weak var addNewBtn: UIButton!
    @IBOutlet weak var inputValue: UITextField!
    
  
    @IBOutlet weak var savedGenres: UILabel!
    
    let db = Firestore.firestore()
    var genres : [String] = []
    
    override func viewDidLoad() {
        print("view has loaded")
        loadGenres()
    }
    
    // adding new genre, if is everything ok
    @IBAction func addNewPressed(_ sender: UIButton) {
        print("button pressed")
        
        if(!inputValue.text!.isEmpty){
            if chechIfCanBeAdded(){
                self.loadGenres()
                self.addGenre()
            }else{
                print("Can not be saved, it is already in db")
            }
        }else{
            print("The input is empty")
        }
    }
    
    // showing saved genres
    func printSavedGenres(genres: [String]){
        var textToPrint = ""
        for g in genres{
            print(g)
            textToPrint.append(g + "\n")
        }
        print("Saved genres")
        print(genres)
        savedGenres.text = textToPrint
    }
    
    // check if the genre is not already saved in db
    func chechIfCanBeAdded() -> Bool{
        var canSave = true
        
        print(inputValue.text!)
        print("Those are loaded genres")
        print(self.genres)
            
        if(!self.genres.isEmpty){
            for g in self.genres{
                if g.lowercased() == inputValue.text!.lowercased(){
                    canSave = false
                }
            }
        }
        return canSave
    }
    
    
    // FIREBASE
    // load genres from Firebase db
    func loadGenres(){
        self.genres = []
        db.collection(K.GenreCollectionName).getDocuments { [self] (querySnapshot, error) in
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            }else{
                print("Loaded documents from Firebase")
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        if let genre = data[K.genre] as? String{
                            self.genres.append(genre)
                        }
                    }
                    print(self.genres)
                    printSavedGenres(genres: self.genres)
                }
            }
        }
        
    }
    
    // adding genre if not already in db
    func addGenre(){
        if let genre = inputValue.text{
            db.collection(K.GenreCollectionName).addDocument(data: [
                K.genre: genre
            ]) { (error) in
                if let e = error{
                    print("There was an issue saving, data to firestore Genre \(e)")
                }else{
                    print("Successfully saved genre data.")
                }
            }
        }
    }
    

}
