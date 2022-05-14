import Foundation
import UIKit
import Firebase

class ChooseTag: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    @IBOutlet weak var pickerViewButton: UIButton!
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // Firestore vars
    let db = Firestore.firestore()
    var infoValues : [[String]] = []
    var firstTimeLoading = true
    
    // genres array
    var genres : [String] = [String]()
    
    // general vars
    let screenWidth = UIScreen.main.bounds.width - 10
    let screenHeight = UIScreen.main.bounds.height / 2
    var selectedGenreRow = 0
    var selectedGenre = ""
    
    // choosing tag vars
    var resultValues : [[String]] = []
    var selectedRow = ""
    var filteredData : [[String]] = []
       
    // inicialization
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        SearchBar.delegate = self
        
        loadBooks()
        loadGenres()
        prolongTheTime()
    }
    
    // loading books from Firebase
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
                            let note = data[K.note] as? String,
                            let genre = data[K.genre] as? String{
                            self.infoValues.append([epc, bookName, authorFirst, authorLast, note, genre])
                        }
                    }
                    print(self.infoValues)
                    self.filteredData = self.infoValues
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // loading available genres
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
    
    // just helping function - something like await
    func prolongTheTime(){
        if (!self.genres.isEmpty){
            _ = self.genres
        }
    }
    
    // auxiliary method for table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(filteredData.count)
        return filteredData.count
    }

    // showing the results - the informations about book/tag
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell( withIdentifier: "SearchCell")!
            
        cell.textLabel?.text = "book name: " + filteredData[indexPath.row][1] + ", author: " + filteredData[indexPath.row][2] + " " + filteredData[indexPath.row][3] + ", tag epc: " + filteredData[indexPath.row][0] + " , genre: " + filteredData[indexPath.row][5]
        print("index path")
        print(indexPath.row)
        cell.textLabel?.textColor = .white
        
        return cell
    }
    
    // selecting row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = filteredData[indexPath.row][0]
        print("selected!!!")
        print(selectedRow)
    }
    
    // setting tag epc to var in another view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! SearchForTagViewController
        destVC.tagEpc = self.selectedRow
    }
    
    // dissmising the keyboard on the phone screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // searching logic function - filtering
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        filteredData = []
        
        if (searchText == "") {
            print("Search text is empty")
            filteredData = infoValues
        }
        
        for book in infoValues{
            print("Book in resultValues")
            print(book)
            if(SearchBar.selectedScopeButtonIndex == 0){
                if(book[1].uppercased().contains(searchText.uppercased()) || book[2].uppercased().contains(searchText.uppercased()) || book[3].uppercased().contains(searchText.uppercased())){
                    filteredData.append(book)
                }
            }else if(SearchBar.selectedScopeButtonIndex == 1){
                if(book[2].uppercased().contains(searchText.uppercased()) || book[3].uppercased().contains(searchText.uppercased())){
                    filteredData.append(book)
                }
            }else if(SearchBar.selectedScopeButtonIndex == 2){
                    if(book[1].uppercased().contains(searchText.uppercased())){
                        filteredData.append(book)
                        
                }
            }
        }
        self.tableView.reloadData()
        
    }
    
    // reloading the list of books on screen
    func reloadFilteredBooks(){
        filteredData = []
        for book in infoValues{
            if(book[5] == selectedGenre){
                filteredData.append(book)
            }
        }
        self.tableView.reloadData()
    }
    
    
    // PICKER
    // setting picker view properties
    @IBAction func pickGenrePressed(_ sender: Any) {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        pickerView.dataSource = self
        pickerView.delegate = self

        pickerView.selectRow(selectedGenreRow, inComponent: 0, animated: false)
        
        vc.view.addSubview(pickerView)
        pickerView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        pickerView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        
        let alert = UIAlertController(title: "Select genre", message: "", preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.sourceView = pickerViewButton
        alert.popoverPresentationController?.sourceRect = pickerViewButton.bounds
        alert.setValue(vc, forKey: "contentViewController")
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(UIAlertAction) in }))
        alert.addAction(UIAlertAction(title: "Select", style: .default, handler: {(UIAlertAction) in
            self.selectedGenreRow = pickerView.selectedRow(inComponent: 0)
            let selected = Array(self.genres)[self.selectedGenreRow]
            print("This was selected")
            print(selected)
            self.selectedGenre = selected
            self.reloadFilteredBooks()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // how many genres to show
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genres.count
    }
    
    // how many components to show
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // returning what name to set on the row in picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genres[row]
    }
    
    // row height to use for drawing row content
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    // setting the label in picker view
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 30))
        label.text = Array(genres)[row]
        label.sizeToFit()
        label.textColor = UIColor.white
        return label
    }
    
   
    
}
