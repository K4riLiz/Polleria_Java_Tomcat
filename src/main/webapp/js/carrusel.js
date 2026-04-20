const carousel = document.getElementById("carousel");
const slides = document.querySelectorAll("#carousel img");
const dots = document.querySelectorAll(".dot");

let index = 0;

function showSlide(i) {
    index = i;

    if (index >= slides.length) index = 0;
    if (index < 0) index = slides.length - 1;

    carousel.style.transform = `translateX(-${index * 100}%)`;

    dots.forEach(dot => dot.classList.remove("bg-white"));
    dots[index].classList.add("bg-white");
}

document.getElementById("next").onclick = () => showSlide(index + 1);
document.getElementById("prev").onclick = () => showSlide(index - 1);

dots.forEach((dot, i) => {
    dot.addEventListener("click", () => showSlide(i));
});

setInterval(() => {
    showSlide(index + 1);
}, 4000);

showSlide(0);