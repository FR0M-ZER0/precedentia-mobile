class HomeRepositoryImpl implements HomeRepository {
	@override
	Future<String> getMessage() async {
		return "Hello, World!"
	}
}