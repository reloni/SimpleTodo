# SimpleToDo

<img src="https://s3.amazonaws.com/task-manager-graphics/app-icon%40iTunesConnect.png" width="100">

Published in App store as [Aika](https://itunes.apple.com/us/app/aika-simple-task-manager/id1240252157)

This app is a simple Task manager that uses [custom backend](https://github.com/reloni/SimpleToDoService) for synchronization and push notification scheduling. It reflects standard iOS Tasks app, but with push notifications (and hopefully more features in the future).
</br>
</br>
<img src="https://s3.amazonaws.com/task-manager-graphics/iPhone+6s+Screens/screenshot_1.png" width="150">
<img src="https://s3.amazonaws.com/task-manager-graphics/iPhone+6s+Screens/screenshot_2.png" width="150">
<img src="https://s3.amazonaws.com/task-manager-graphics/iPhone+6s+Screens/screenshot_3.png" width="150">
<img src="https://s3.amazonaws.com/task-manager-graphics/iPhone+6s+Screens/screenshot_4.png" width="150">

## Main features implemented to this time:
- Push notifications
- Synchronization across all iOS devices
- Offline mode
- Social login (Google and Facebook)

App uses Redux-like architecture for state management and routing. I wrote my own implementation, similar to ReSwift, that I call [RxDataFlowController](https://github.com/reloni/RxDataFlow) and this app is proof of concept.
