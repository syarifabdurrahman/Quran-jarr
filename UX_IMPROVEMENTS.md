# Quran Jar - UX Improvements Tracker

## App Purpose
A daily motivation jar for Quran verses - users tap a jar to receive a verse each day.

---

## Critical Priority

### 1. Daily Streak System
- [ ] Add streak counter (consecutive days of reading)
- [ ] Display streak on main screen: "Day 12 of daily reading"
- [ ] Streak notification: "You're on a 7-day streak!"
- [ ] Milestone celebrations (7 days, 30 days, 100 days)
- [ ] Visual progress indicator on jar screen

### 2. Ritual Moment Experience
- [ ] Add anticipation delay before verse reveal (1-2 seconds)
- [ ] Smoother jar shake animation
- [ ] Paper slip animation improvement
- [ ] Sound effect on verse pull (optional)
- [ ] "Breath" moment - pause before showing actions

### 3. Time-Aware Personalization
- [ ] Morning greeting: "Good morning! Start your day with inspiration"
- [ ] Evening greeting: "Evening reflection time"
- [ ] Time-of-day aware UI (calmer colors at night)

---

## High Priority

### 4. Progress Motivation
- [ ] Daily verse counter: "2/3 verses today"
- [ ] Progress bar showing daily limit
- [ ] Weekly/monthly stats
- [ ] "You've read 50 verses this month!"

### 5. Limit Feedback Improvement
- [ ] Replace confusing message with clear feedback
- [ ] Show: "You've read 3/3 verses today! Come back tomorrow"
- [ ] Visual countdown: "Next verse in: 12 hours"
- [ ] Softer color for limit reached state

### 6. Empty State & First Experience
- [ ] First-time user tutorial
- [ ] Clear call-to-action when jar is empty
- [ ] Celebrate first verse pull
- [ ] Share your first verse prompt

---

## Medium Priority

### 7. Reflection Space
- [ ] Add "reflect moment" before showing actions
- [ ] Optional journaling feature for thoughts
- [ ] Mood tracker with verse
- [ ] Prayer reminder after reading

### 8. Delight & Celebration
- [ ] Confetti animation on streak milestones
- [ ] Special jar appearance on milestones
- [ ] Achievement badges
- [ ] Share streak progress

### 9. Archive Enhancement
- [ ] "This day last month" feature
- [ ] Verse of the week/month
- [ ] Sort by mood/topic
- [ ] Search by surah or keyword

### 10. Notification Experience
- [ ] Personalized notification messages
- [ ] Time-aware notifications
- [ ] Gentle reminder style
- [ ] Notification with verse preview

---

## Low Priority

### 11. Visual Polish
- [ ] Jar fills up with paper slips over time
- [ ] Different jar themes/seasons
- [ ] Animated background
- [ ] Particle effects on tap

### 12. Social Features
- [ ] Share streak with friends
- [ ] Family jar (shared daily verse)
- [ ] Community verse of the day

### 13. Accessibility
- [ ] Screen reader support
- [ ] High contrast mode
- [ ] Font size accessibility
- [ ] Reduced motion option (done)

---

## Completed Improvements

### ✅ Dark Mode
- Midnight Reflection theme
- Theme switching in Settings

### ✅ Accessibility
- Reduced motion preference
- System text scaling

### ✅ Settings Restructured
- Appearance section
- Accessibility section

### ✅ Interaction Polish
- Haptic feedback on jar tap
- Empty state hint

### ✅ Share Experience
- Theme-aware share sheet
- App branding in shares

### ✅ Navigation
- Back buttons
- Theme-aware colors

### ✅ Skeleton Loaders
- Shimmer effect for loading

---

## Metrics to Track

### Engagement Metrics
- Daily Active Users (DAU)
- Streak retention rate
- Verses read per user per day
- Time spent reading verse

### Feature Usage
- Archive save rate
- Share rate
- Tafsir view rate
- Notification click rate

---

## Implementation Notes

### Streak System Data Model
```dart
class UserStreak {
  int currentStreak;
  int longestStreak;
  DateTime lastReadDate;
  int totalVersesRead;
  int versesReadToday;
}
```

### Time-Aware Greeting
```dart
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return "Good morning";
  if (hour < 17) return "Good afternoon";
  return "Good evening";
}
```

### Progress Bar Logic
```dart
double get dailyProgress {
  return versesReadToday / dailyLimit;
}
```
