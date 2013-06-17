function PhotoCtrl($scope) {

	$scope.photos = [];
	$scope.socket = io.connect(window.location.protocol + "//" + window.location.host);

	$scope.byCreatedTime = function(photo) {
  		return parseInt(photo.created_at);
  	}

	$scope.socket.on('bootstrap', function(photos) {
		console.log('bootstrap', photos);
		$scope.$apply(function(scope) {
			scope.photos = photos;
		});
	});	

	$scope.socket.on('new', function(photo) {
		console.log('new', photo);
		$scope.$apply(function(scope){
			scope.photos.push(photo);
		});
	});

}