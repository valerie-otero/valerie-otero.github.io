document.addEventListener("DOMContentLoaded", function() {
    // --- Card Animation ---
    const cards = document.querySelectorAll('.app-card');

    const observerOptions = {
        threshold: 0.15,
        rootMargin: "0px 0px -50px 0px"
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry, index) => {
            if (entry.isIntersecting) {
                // Staggered delay based on index
                setTimeout(() => {
                    entry.target.classList.add('visible');
                }, index * 100); 
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    cards.forEach(card => {
        observer.observe(card);
    });

    // --- Parallax Hero Effect ---
    const hero = document.querySelector('.hero');
    const heroTitle = document.querySelector('.hero h2');
    const heroText = document.querySelector('.hero p');

    window.addEventListener('scroll', () => {
        const scrollY = window.scrollY;
        if (scrollY < 600) { // Only animate if visible
            heroTitle.style.transform = `translateY(${scrollY * 0.2}px)`;
            heroTitle.style.opacity = 1 - scrollY / 400;
            
            heroText.style.transform = `translateY(${scrollY * 0.15}px)`;
            heroText.style.opacity = 1 - scrollY / 400;
        }
    });
});
