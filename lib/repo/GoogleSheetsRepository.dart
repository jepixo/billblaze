abstract class GoogleSheetsRepository {
  Future<void> createAndModifySheet(String accessToken, String userEmail, List<List<Object>> data);
  Future<void> revokePermissions();
}