This app is a simple Task manager that uses [custom backend](https://github.com/reloni/SimpleToDoService) for synchronization and push notification scheduling. It reflects standard iOS Tasks app, but with push notifications (and hopefully more features in the future).

App uses Redux-like architecture for state management and routing. I wrote my own implementation, similar to ReSwift, that I call [RxDataFlowController](https://github.com/reloni/RxDataFlow) and this app is proof of concept.

Main part of the app lies in DataFlow folder, here are state of application, actions and reducers (entities that decides what app should do according to dispatched action).

AppCoordinator - folder with coordinators, entities that coordinates transitions between View Controllers.

Every ViewController has it's own ViewModel. And ViewModel actually decides what kind of action should be dispatched.

Carthage used for dependency management. Use "carthage update --platform ios" command for update dependencies.
