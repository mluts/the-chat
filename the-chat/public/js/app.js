(function(root) {
  angular.module('myApp', ['base64'])
    .config(['$httpProvider', function($httpProvider){
      $httpProvider.defaults.headers.Accept = 'application/vnd.the-chat-v1+json';
    }])
    .service('api', ['$base64', '$http', function($base64, $http) {
      this.getProfile = function(name, pass) {
        return $http.get('/api/profile', {
          headers: {
            'Authorization': $base64.encode("Basic " + [name,pass].join(':'))
          }
        });
      }
    }])
    .service('auth', ['base64', '$http', 'api', function(base64, $http, api){
    }])
    .controller('main', ['$scope', '$http', function($scope, $http) {
    }])
}(this));
