# Code Citations

## License: unknown
https://github.com/alsanati/sugartracker/tree/77bba28e5ce65c52d1b89b61f6d7533159abd8db/lib/app/features/auth/account_page.dart

```
),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot
```


## License: unknown
https://github.com/jpl12345/parkpark_public/tree/98555ef3aa0f00a53e2136bdd1a627874a4260aa/parkpark_public/lib/parkCarparkPage.dart

```
, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'))
```


## License: unknown
https://github.com/EgemenArda/GameChattt/tree/9c34472c5962161d317ad0c3dd7ee489468903c1/lib/screens/game_rooms.dart

```
waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.
```


## License: BSD_3_Clause
https://github.com/aziabatz/barry-barrel-flutter/tree/c080f7cdd8a583f318a8b3c5a2cf4f8858a163f6/lib/ui/details/details_screen.dart

```
child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return
```


## License: unknown
https://github.com/ZawLwinTunSCM/ChatApp/tree/bd8d3b6171b101e134f10bfa866ac6f1d0b10938/lib/presentation/chats/chat_room.dart

```
} else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text(
```

