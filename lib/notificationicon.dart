import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NotificationIcon extends StatefulWidget {
    const NotificationIcon({super.key});

    @override
    State<NotificationIcon> createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
    final int _notificationCount = 0;

    @override
    Widget build(BuildContext context) {
    return Stack(
        children: [
        IconButton(
            onPressed: () {},
            icon: const Icon(Iconsax.notification),
        ),
        if (_notificationCount > 0)
            Positioned(
            top: 0,
            right: 0,
            child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
                ),
                constraints: const BoxConstraints(
                minWidth: 12,
                minHeight: 12,
                ),
                child: Text(
                '$_notificationCount',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                ),
                textAlign: TextAlign.center,
                ),
            ),
            ),
        ],
    );
    }
}