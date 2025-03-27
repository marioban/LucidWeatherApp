//
//  HistoryViewController.swift
//  LucidWeatherApp
//
//  Created by Mario Ban on 25.03.2025..
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {
    @IBOutlet weak var segmentedUnits: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<Forecast>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.largeContentTitle = "Saved searches"
        view.backgroundColor = .systemBackground
        
        tableView.register(HistoryTableViewCell.nib(), forCellReuseIdentifier: HistoryTableViewCell.identifier)
        configureFetchedResultsController()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configureFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Forecast> = Forecast.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let context = CoreDataService.shared.context
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
            
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch forecasts: \(error.localizedDescription)")
            showAlert(withTitle: "Error", message: "Failed to fetch saved forecasts: \(error.localizedDescription)")
        }
    }
    
    @IBAction func unitsSwitch(_ sender: UISegmentedControl) {
        updateUI()
    }
    
}

extension HistoryViewController {
    func updateUI() {
        tableView.reloadData()
    }
    
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as? HistoryTableViewCell else {
            return UITableViewCell()
        }
        
        let record = fetchedResultsController.object(at: indexPath)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: record.date ?? Date())
        let city = record.cityName ?? "Unknown"
        let tempMetric = record.temperature
        
        if segmentedUnits.selectedSegmentIndex == 0 {
            cell.temperature.text = String(format: "%.1f°C", tempMetric)
        } else {
            let tempF = tempMetric * 9/5 + 32
            cell.temperature.text = String(format: "%.1f°F", tempF)
        }
        
        cell.date.text = dateString
        cell.cityName.text = city
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = CoreDataService.shared.context
            let recordToDelete = fetchedResultsController.object(at: indexPath)
            context.delete(recordToDelete)
            
            do {
                try context.save()
            } catch  {
                print("Failed deleting record: \(error.localizedDescription)")
                showAlert(withTitle: "Error", message: "Failed to delete record: \(error.localizedDescription)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension HistoryViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<any NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        @unknown default:
            fatalError("Unknown change type in NSFetchedResultsController")
        }
    }
}
