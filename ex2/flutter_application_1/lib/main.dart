import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ResponsiveGridView(),
  ));
}

class ResponsiveGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine the number of items per row and the background color based on the width
          int itemsPerRow;
          Color bgColor;

          if (constraints.maxWidth < 400) {
            itemsPerRow = 1; // Display 1 item per row for small screens
            bgColor = Colors.red.shade200;
          } else if (constraints.maxWidth < 800) {
            itemsPerRow = 2; // Display 2 items per row for medium screens
            bgColor = Colors.orange.shade200;
          } else {
            itemsPerRow = 4; // Display 4 items per row for large screens
            bgColor = Colors.green.shade200;
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: itemsPerRow,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 12, // Limit the number of items to 12
            itemBuilder: (context, index) {
              return Container(
                color: bgColor,
                child: Center(
                  child: Text(
                    'Item ${index + 1}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
            padding: EdgeInsets.all(10),
          );
        },
      ),
    );
  }
}
