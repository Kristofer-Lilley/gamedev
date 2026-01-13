#include <SFML/Graphics.hpp>
#include <string>

int main()
{
    sf::RenderWindow window(sf::VideoMode(1000, 1000), "SFML works!");
    sf::RectangleShape rectangle(sf::Vector2f(120.f, 120.f));
    sf::RenderTarget::clear (const Color & color = Color(255, 255, 255, 255));
    rectangle.setPosition(sf::Vector2f(0.f, 0.f));
    rectangle.setFillColor(sf::Color::Green);

    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();

            if (sf::Keyboard::isKeyPressed(sf::Keyboard::Left))
            {
                rectangle.move(-5.f, 0.f);
            }
            if (sf::Keyboard::isKeyPressed(sf::Keyboard::Right))
            {
                rectangle.move(5.f, 0.f);
            }
            if (sf::Keyboard::isKeyPressed(sf::Keyboard::Up))
            {
                rectangle.move(0.f, -5.f);
            }
            if (sf::Keyboard::isKeyPressed(sf::Keyboard::Down))
            {
                rectangle.move(0.f, 5.f);
            }
        }

        window.clear();
        window.draw(rectangle);
        window.display();
    }

    return 0;
}


