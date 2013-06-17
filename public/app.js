function PhotoCtrl($scope) {

	$scope.photos = [];
	$scope.socket = io.connect(window.location.protocol + "//" + window.location.host);

	$scope.byCreatedTime = function(photo) {		
  		return -1* parseInt(photo.created_time);
  	}

  	$scope.isoTime = function(photo) {
  		return new Date(parseInt(photo.created_time)*1000).toISOString()
  	}

	$scope.socket.on('bootstrap', function(photos) {
		//console.log('bootstrap', photos);
		$scope.$apply(function(scope) {
			scope.photos = photos;
		});
	});	

	$scope.socket.on('new', function(photo) {
		//console.log('new', photo);
		$scope.$apply(function(scope){			
			scope.photos.push(photo);
		});
	});

}