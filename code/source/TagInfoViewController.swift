import UIKit
import NurAPIBluetooth
import FirebaseFirestore
import FirebaseAuth

class TagInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    // outlets for labels and buttons,...
    @IBOutlet weak var BookNameField: UITextField!
    @IBOutlet weak var NoteField: UITextField!
    @IBOutlet weak var AuthorLast: UITextField!
    @IBOutlet weak var AuthorFirst: UITextField!
    @IBOutlet weak var HelpPressed: UIButton!
    @IBOutlet weak var btnSavePressed: UIButton!
    @IBOutlet weak var btnDeletePressed: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var pickerViewButton: UIButton!
   
    // Firestore instance and vars to store data from Firebase
    let db = Firestore.firestore()
    var firstTimeLoading = true
    var infoValues : [[String]] = []
    var genres : [String] = [String]()
    
    // general settings
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 2
    var selectedRow = 0
    var selectedGenre = ""
    
    // the tag we operate on
    var tag: Tag!
    var canBeSaved: Bool!
    var isSaved = false

    // informations about tag
    enum InfoType : Int {
        case epc = 0
        case channel
        case rssi
        case timestamp
        case frequency
        case antennaId
        case scaledRssi

        var text: String {
            switch self {
            case .epc: return "EPC"
            case .channel: return "Channel"
            case .rssi: return "RSSI "
            case .scaledRssi: return "Scaled RSSI"
            case .timestamp: return "Timestamp"
            case .frequency: return "Frequency"
            case .antennaId: return "Antenna Id"
            }
        }
   }

    // setting the scene after loading the view
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        loadBooks()
        loadGenres()
        prolongTheTime()
        
        BookNameField.attributedPlaceholder =
            NSAttributedString(string: " * Enter book name", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        NoteField.attributedPlaceholder =
            NSAttributedString(string: " Enter some notes", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        AuthorFirst.attributedPlaceholder =
            NSAttributedString(string: " * Enter author firstname", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        AuthorLast.attributedPlaceholder =
            NSAttributedString(string: " * Enter author lastname", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
    }

    // dismissing/hiding the keyboard on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        BookNameField.resignFirstResponder()
        AuthorFirst.resignFirstResponder()
        AuthorLast.resignFirstResponder()
        NoteField.resignFirstResponder()
    }
    
    // checking if the tag is already in db, if yes, it can not be saved without deleting it from db first
    func checkIfIsInDatabase(){
        if self.firstTimeLoading{
            for item in self.infoValues{
                if !item.isEmpty{
                    if(tag.epc == item[0]){
                        self.stateLabel.text = "The book is already saved in the database as " + item[1] + ". If you want to make change, delete it and then save new version."
                        self.stateLabel.textColor = UIColor.orange
                    }
                }
            }
            
        }
        self.firstTimeLoading = false
    }
    
    // just helping functin, something like await
    func prolongTheTime(){
        if (!self.genres.isEmpty){
            _ = self.genres

        }
    }
    
    
    //  FIREBASE
    // adding book to db
    func addToList(){
        let tag_epc = tag.epc
        let selectedGenreLoc = self.selectedGenre
        
        if let bookName = BookNameField.text,
           let authorFirst = AuthorFirst.text,
           let authorLast = AuthorLast.text,
           let note = NoteField.text,
           let user = Auth.auth().currentUser?.email
           {
            
            db.collection(K.CollectionName).document(tag_epc).setData([
                K.epc: tag_epc,
                K.bookName: bookName,
                K.authorFirst: authorFirst,
                K.authorLast: authorLast,
                K.note: note,
                K.genre: selectedGenreLoc,
                K.sender: user
            ]) { (error) in
                if let e = error{
                    print("There was an issue saving, data to firestore \(e)")
                }else{
                    print("Successfully saved data.")
                }
            }
        }
        
    }
    
    // loading books from db
    func loadBooks(){
        infoValues = []
        db.collection(K.CollectionName).getDocuments { (querySnapshot, error) in
            if let e = error {
                print("There was an issue retrieving data from Firestore. \(e)")
            }else{
                print("Loaded documents from Firebase")
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments{
                        let data = doc.data()
                        if let epc = data[K.epc] as? String,
                            let bookName = data[K.bookName] as? String,
                            let authorFirst = data[K.authorFirst] as? String,
                            let authorLast = data[K.authorLast] as? String,
                            let note = data[K.note] as? String{
                            self.infoValues.append([epc, bookName, authorFirst, authorLast, note])
                        }
                    }
                    print(self.infoValues)
                    self.checkIfIsInDatabase()
                }
            }
        }
    }
    
    // deleting book from db
    func deleteFromFirestore(){
        db.collection(K.CollectionName).document(tag.epc).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    // loading genres from db
    func loadGenres(){
        self.genres = []
        db.collection(K.GenreCollectionName).getDocuments { (querySnapshot, error) in
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
                }
            }
        }
    }
    
    // returning the number of rows to show in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    // setting the table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagInfoCell", for: indexPath)
        
        guard let type = InfoType(rawValue: indexPath.row) else {
            cell.textLabel?.text = "Invalid"
            cell.detailTextLabel?.text = "Invalid"
            return cell
        }

        cell.textLabel?.text = type.text

        switch type {
        case .epc: cell.detailTextLabel?.text = tag.epc
        case .channel: cell.detailTextLabel?.text = "\(tag.channel)"
        case .rssi: cell.detailTextLabel?.text = "\(tag.rssi) dB"
        case .scaledRssi: cell.detailTextLabel?.text = "\(tag.scaledRssi) dB"
        case .timestamp: cell.detailTextLabel?.text = "\(tag.timestamp)"
        case .frequency: cell.detailTextLabel?.text = "\(tag.frequency) Hz"
        case .antennaId: cell.detailTextLabel?.text = "\(tag.antennaId)"
        }
        
        return cell
    }
    
 
    
    // Genres picker - necessary settings
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print("This is number of genres")
        print(genres.count)
        return genres.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genres[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    // setting labels to picker view
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        label.text = Array(genres)[row]
        label.sizeToFit()
        label.textColor = UIColor.white
        return label
    }
    
    // the popUpPicker general settings
    @IBAction func popUpPicker(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        pickerView.dataSource = self
        pickerView.delegate = self

        pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        
        let alert = UIAlertController(title: "Select genre", message: "", preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.sourceView = pickerViewButton
        alert.popoverPresentationController?.sourceRect = pickerViewButton.bounds
        alert.setValue(vc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(UIAlertAction) in }))
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: {(UIAlertAction) in
            self.selectedRow = pickerView.selectedRow(inComponent: 0)
            let selected = Array(self.genres)[self.selectedRow]
            print("This was selected")
            print(selected)
            self.selectedGenre = selected
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // after button pressed, save book to db, if everything is ok
    @IBAction func SaveTag(_ sender: UIButton) {
        self.isSaved = false
        var bookName = ""
        for item in infoValues{
            if !item.isEmpty{
                if(tag.epc == item[0]){
                    self.isSaved = true
                    bookName = item[1]
                }
            }
        }
        if(AuthorFirst.text != "" && BookNameField.text != "" && NoteField != nil && AuthorLast.text != "" && selectedGenre != ""){
            if(self.isSaved == false){
                btnSavePressed.setTitle("Tag added!", for: .normal)
                btnSavePressed.setTitleColor(.white, for: .normal)
                self.stateLabel.text = "Everything is OK."
                self.stateLabel.textColor = UIColor.green
            }else{
                btnSavePressed.setTitle("Tag not added!", for: .normal)
                btnSavePressed.setTitleColor(.white, for: .normal)
                self.stateLabel.text = "The book is already in database as " + bookName + ", it can not be saved"
                self.stateLabel.textColor = UIColor.orange
                return
            }
            print(AuthorFirst.text ?? "empty author first")
            print(AuthorLast.text ?? "empty author last")
            print(BookNameField.text ?? "empty book")
            print(NoteField.text ?? "empty note")
            
            addToList()
            loadBooks()
        }else{
            self.stateLabel.text = "Some fields were not filled correctly!"
            self.stateLabel.textColor = UIColor.red
            btnSavePressed.setTitle("Tag not added!", for: .normal)
            btnSavePressed.setTitleColor(.red, for: .normal)
        }
    }
    
    // the help with the name of the author - if this author is already in db, show his full name
    @IBAction func HelpWithLastnamePressed(_ sender: UIButton) {
        var helpString = ""
        if(AuthorFirst.text != ""){
            for item in infoValues{
                if(!item.isEmpty){
                    if item[2].lowercased().contains(AuthorFirst.text!.lowercased()) {
                        helpString.append(item[2] + " " + item[3] + "\n")
                        print(item[2], item[3])
                    }
                }else{
                    print("item is empty")
                }
            }
            if (!helpString.isEmpty){
                self.stateLabel.text = "We found these authors: " + helpString
            }else{
                self.stateLabel.text = "No suggestions were found"
            }
        }else{
            print("empty fistname")
        }
    }
    
    // deleting from db the book
    @IBAction func DeletePressed(_ sender: UIButton) {
        
        deleteFromFirestore()
    }
    
}
