import 'package:flutter/material.dart';

class TaskPlannerScreen extends StatelessWidget {
  const TaskPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              width: double.infinity, // Adjust if needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, left: 20, right: 20),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Whatbytes",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,  // This makes the text italic
                            color: const Color.fromARGB(184, 10, 32, 129),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 120.0, left: 90, right: 20, bottom: 20), // Adjusted padding for content
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        AnimatedGlowImage(), // Animated Image
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 50), // Adjusted padding for description
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Get things done.",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: const Color.fromARGB(184, 10, 32, 129),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Just a click away from\nplanning your tasks.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 150),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -150, // Positioned at the bottom of the screen
            left: 180,  // Move the button to the left to make it cross the screen
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/signup'); // Navigate to the signup page
              },
              child: Container(
                width: 320, // Extending width beyond screen
                height: 320,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 44, 73, 236),
                  borderRadius: BorderRadius.circular(200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 40.0,bottom: 130), // Adjusted padding
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedGlowImage extends StatefulWidget {
  const AnimatedGlowImage({super.key});

  @override
  _AnimatedGlowImageState createState() => _AnimatedGlowImageState();
}

class _AnimatedGlowImageState extends State<AnimatedGlowImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(_glowAnimation.value),
                spreadRadius: 10,
                blurRadius: 20,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'lib/Screenshot 2025-02-05 223126.png',
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }
}
