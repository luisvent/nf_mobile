import 'package:nf_mobile/database/storage_manager.dart';
import 'package:nf_mobile/interface/LoanNotes.dart';

class LoanNoteStorage extends StorageManager {
  var filename = 'notes_data';

  LoanNoteStorage() : super();

  Future<bool> AddLoanNote(dynamic noteData) async {
    final notes = await GetNotesData();
    notes.add(noteData);
    return StoreData(notes);
  }

  Future<bool> AddLoanNotes(dynamic notesData) async {
    return StoreData(notesData);
  }

  Future<List<LoanNotes>> GetNotesData() async {
    final storeData = await GetData();
    if (storeData.error) {
      return [];
    } else {
      return storeData.data.map<LoanNotes>((e) => new LoanNotes.fromJson(e)).toList();
    }
  }
}
