# Angular in Sinatra

## Why?

It's fairly difficult to hash angular templates. Even if it's not state of the art anymore, it's always good to know how to do these things. 

## How?

First, see how to load sprockets in sinatra, and sinatra itself. 

Add partials to assets dir (under `partials/`).

Now you have to erb-ify the main js file, because you want to get the fingerprints in the urls:

```js
// app.js.erb
var mainApp = angular.module('mainApp', [
  'ngRoute'
]);

...

mainApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/taxes', {
        templateUrl: '<%= asset_path 'taxes.html', asset_host: false %>',
        controller: 'TaxesController'
       }).
  ....
 }]);
```
